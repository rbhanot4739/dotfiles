---@class CodeCompanion.Extension.ChatModelToggle
---@field setup fun(opts: table): any Function called when extension is loaded
---@field exports? table Optional table of functions exposed via codecompanion.extensions.name

-- Safe logging
local log = {}
local ok, codecompanion_log = pcall(require, "codecompanion.utils.log")
if ok and codecompanion_log then
  log = codecompanion_log
else
  log.trace = function(...) end
  log.debug = function(...) end
  log.info = function(...) end
  log.warn = function(...) end
  log.error = function(...) end
end

local M = {}
local in_memory_cache = {}

-- Configuration
local CONFIG = {
  cache_file = "/tmp/codecompanion_copilot_models.json",
  cache_duration = 7 * 24 * 60 * 60, -- 7 days in seconds
  fetch_enabled = false, -- Prevents startup calls
}

-- Model constants
local FALLBACK_MODELS = {
  "gpt-4.1",
  "gpt-4o",
  "o3-mini",
  "claude-3.5-sonnet",
  "claude-3.7-sonnet",
  "claude-3.7-sonnet-thought",
  "claude-sonnet-4",
  "claude-opus-4",
  "gemini-2.0-flash-001",
  "gemini-2.5-pro-preview-06-05",
  "o3",
  "o4-mini",
}

local PREDEFINED_MODELS = {
  anthropic = {
    "claude-3-5-sonnet-20241022",
    "claude-3-5-haiku-20241022",
    "claude-3-opus-20240229",
    "claude-3-sonnet-20240229",
    "claude-3-haiku-20240307",
  },
  openai = {
    "gpt-4o",
    "gpt-4o-mini",
    "gpt-4-turbo",
    "gpt-4",
    "gpt-3.5-turbo",
    "o1-preview",
    "o1-mini",
  },
  gemini = {
    "gemini-2.0-flash-exp",
    "gemini-1.5-pro",
    "gemini-1.5-flash",
    "gemini-1.5-flash-8b",
  },
}

-- Cache utilities
local function read_cache()
  local file = io.open(CONFIG.cache_file, "r")
  if not file then
    return nil, 0
  end

  local content = file:read("*all")
  file:close()

  local ok, data = pcall(vim.json.decode, content)
  if not ok or not data or not data.models or not data.timestamp then
    return nil, 0
  end

  return data.models, data.timestamp
end

local function write_cache(models, timestamp)
  local file = io.open(CONFIG.cache_file, "w")
  if not file then
    return false
  end

  local ok, json = pcall(vim.json.encode, { models = models, timestamp = timestamp })
  if not ok then
    file:close()
    return false
  end

  file:write(json)
  file:close()
  return true
end

local function is_cache_fresh(timestamp)
  return timestamp and timestamp > 0 and (os.time() - timestamp) < CONFIG.cache_duration
end

local function cache_exists()
  local file = io.open(CONFIG.cache_file, "r")
  if file then
    file:close()
    return true
  end
  return false
end

local function get_cache_age_days()
  local _, timestamp = read_cache()
  return timestamp > 0 and math.floor((os.time() - timestamp) / (24 * 60 * 60)) or 0
end

local function get_copilot_models()
  -- Return fallback models if fetching is disabled (prevents startup calls)
  if not CONFIG.fetch_enabled then
    if log.trace then
      log:trace("Fetch disabled, returning fallback models")
    end
    return FALLBACK_MODELS
  end

  local cached_models, timestamp = read_cache()

  -- Use cached models if they are fresh
  if cached_models and is_cache_fresh(timestamp) then
    if log.trace then
      log:trace("Using fresh cached models (%d models, %d days old)", #cached_models, get_cache_age_days())
    end
    return cached_models
  end

  -- Fetch fresh models if cache is stale or doesn't exist
  if log.trace then
    log:trace("Cache stale or missing, fetching fresh models...")
  end

  local handle = io.popen("zsh -c 'source ~/.zshrc && ghm' 2>&1")
  if handle then
    local result = handle:read("*a")
    handle:close()

    if result and result ~= "" then
      local fresh_models = {}
      for line in result:gmatch("[^\r\n]+") do
        local clean_line = line:gsub("\27%[[%d;]*m", ""):gsub("[%c%z]", ""):match("^%s*(.-)%s*$")
        local model = clean_line:match("(gpt[%w%-%._]*)")
          or clean_line:match("(claude[%w%-%._]*)")
          or clean_line:match("(gemini[%w%-%._]*)")
          or clean_line:match("(o%d+[%w%-%._]*)")
          or clean_line:match("([%a][%w%-%._]*)")

        if model and #model >= 3 and #model <= 50 and model:match("^[%w][%w%-%._]*$") then
          table.insert(fresh_models, model)
        end
      end

      if #fresh_models > 0 then
        write_cache(fresh_models, os.time())
        if log.trace then
          log:trace("Fetched and cached %d fresh models", #fresh_models)
        end
        return fresh_models
      end
    end
  end

  -- Fallback to stale cache or hardcoded models
  if cached_models then
    vim.notify(
      "Failed to fetch fresh models, using cached list",
      vim.log.levels.WARN,
      { title = "CodeCompanion Model Picker" }
    )
    return cached_models
  end

  vim.notify(
    "Failed to fetch models, using fallback list",
    vim.log.levels.WARN,
    { title = "CodeCompanion Model Picker" }
  )
  write_cache(FALLBACK_MODELS, os.time())
  return FALLBACK_MODELS
end

-- Model retrieval for different adapters
local function get_adapter_models(adapter_name, adapter)
  -- Use in-memory cache first for performance
  if in_memory_cache[adapter_name] then
    if log.trace then
      log:trace("Using in-memory cache for adapter: %s", adapter_name)
    end
    return in_memory_cache[adapter_name]
  end

  -- Try adapter schema first
  if adapter.schema and adapter.schema.model and adapter.schema.model.choices then
    local choices = adapter.schema.model.choices
    if type(choices) == "function" then
      local ok, result = pcall(choices)
      if ok and type(result) == "table" and #result > 0 then
        in_memory_cache[adapter_name] = result
        return in_memory_cache[adapter_name]
      end
    elseif type(choices) == "table" and #choices > 0 then
      in_memory_cache[adapter_name] = choices
      return in_memory_cache[adapter_name]
    end
  end

  -- Use dynamic or predefined models
  if adapter_name == "copilot" then
    in_memory_cache[adapter_name] = get_copilot_models()
    return in_memory_cache[adapter_name]
  end

  in_memory_cache[adapter_name] = PREDEFINED_MODELS[adapter_name] or {}
  return in_memory_cache[adapter_name]
end

-- Chat utilities
local function get_current_chat()
  -- Try chat strategy
  local ok, chat_strategy = pcall(require, "codecompanion.strategies.chat")
  if ok and chat_strategy and chat_strategy.last_chat then
    local chat = chat_strategy.last_chat()
    if chat then
      return chat
    end
  end

  -- Try current buffer
  local buf = vim.api.nvim_get_current_buf()
  local ok_ft, filetype = pcall(vim.api.nvim_get_option_value, "filetype", { buf = buf })
  if ok_ft and filetype == "codecompanion" then
    local ok_var, chat = pcall(vim.api.nvim_buf_get_var, buf, "codecompanion_chat")
    if ok_var and chat then
      return chat
    end
  end

  -- Try codecompanion current_chat
  local ok_cc, codecompanion = pcall(require, "codecompanion")
  if ok_cc and codecompanion.current_chat then
    return codecompanion.current_chat()
  end

  return nil
end

-- UI functions
local function show_model_picker(models, current_model, callback)
  local display_items = {}
  local model_map = {}

  for _, model in ipairs(models) do
    local display_text = model == current_model and model .. " (current)" or model
    table.insert(display_items, display_text)
    model_map[display_text] = model
  end

  vim.ui.select(display_items, {
    prompt = "Select model:",
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if choice then
      callback(model_map[choice])
    end
  end)
end

local function apply_model_to_chat(chat, new_model, old_model)
  local ok, err = pcall(chat.apply_model, chat, new_model)
  if not ok then
    vim.notify(
      "Failed to apply model: " .. (err or "unknown error"),
      vim.log.levels.ERROR,
      { title = "CodeCompanion Model Picker" }
    )
    return
  end

  vim.notify(
    string.format("Switched from %s to %s", old_model, new_model),
    vim.log.levels.INFO,
    { title = "CodeCompanion Model Picker" }
  )

  if log.trace then
    log:trace("Model changed from %s to %s", old_model, new_model)
  end
end

local function show_picker(chat, opts)
  if not chat then
    vim.notify("No active chat found", vim.log.levels.WARN, { title = "CodeCompanion" })
    return
  end

  -- Enable fetching when user uses the picker
  CONFIG.fetch_enabled = true

  local adapter_name = chat.adapter.name
  local current_model = chat.adapter.schema.model.default
  local available_models = get_adapter_models(adapter_name, chat.adapter)

  if #available_models == 0 then
    vim.notify("No models available for adapter: " .. adapter_name, vim.log.levels.WARN, { title = "CodeCompanion" })
    return
  end

  show_model_picker(available_models, current_model, function(selected_model)
    if selected_model and selected_model ~= current_model then
      apply_model_to_chat(chat, selected_model, current_model)
    end
  end)
end

function M.setup(opts)
  opts = opts or {}
  local config = vim.tbl_deep_extend("force", {
    keymaps = {
      pick_model = "gm",
      refresh_models = "gM",
    },
  }, opts)

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "codecompanion",
    callback = function(args)
      -- Keymap for picking a model
      if config.keymaps.pick_model then
        vim.keymap.set("n", config.keymaps.pick_model, function()
          show_picker(get_current_chat(), config)
        end, {
          desc = "Show model picker",
          buffer = args.buf,
        })
      end

      -- Keymap for refreshing models
      if config.keymaps.refresh_models then
        vim.keymap.set("n", config.keymaps.refresh_models, function()
          local chat = get_current_chat()
          if not chat then
            vim.notify("No active chat found to refresh models for.", vim.log.levels.WARN, { title = "CodeCompanion" })
            return
          end

          vim.notify("Refreshing Copilot models...", vim.log.levels.INFO, { title = "CodeCompanion" })
          local models = M.exports.refresh_copilot_models()

          if models and #models > 0 then
            vim.notify(
              string.format("Refreshed and cached %d models.", #models),
              vim.log.levels.INFO,
              { title = "CodeCompanion" }
            )
            -- Now show the picker with the new models
            show_picker(chat, config)
          else
            vim.notify("Failed to refresh models.", vim.log.levels.WARN, { title = "CodeCompanion" })
          end
        end, {
          desc = "Refresh Copilot models and show picker",
          buffer = args.buf,
        })
      end
    end,
  })

  if log.trace then
    log:trace("Chat model picker extension loaded with keymaps: %s", vim.inspect(config.keymaps))
  end

  return M
end

M.exports = {
  show_model_picker = function(opts)
    show_picker(get_current_chat(), opts or {})
  end,
  get_current_model = function()
    local chat = get_current_chat()
    return chat and chat.adapter.schema.model.default or nil
  end,
  get_available_models = function()
    local chat = get_current_chat()
    return chat and get_adapter_models(chat.adapter.name, chat.adapter) or {}
  end,
  refresh_copilot_models = function()
    CONFIG.fetch_enabled = true
    os.remove(CONFIG.cache_file)
    in_memory_cache.copilot = nil -- Invalidate in-memory cache
    return get_copilot_models()
  end,
  get_cache_info = function()
    local cached_models, timestamp = read_cache()
    return {
      cache_exists = cache_exists(),
      has_cached_models = cached_models ~= nil,
      cached_count = cached_models and #cached_models or 0,
      cache_age_days = get_cache_age_days(),
      is_cache_fresh = is_cache_fresh(),
      fetch_enabled = CONFIG.fetch_enabled,
      cache_file = CONFIG.cache_file,
    }
  end,
}

return M
