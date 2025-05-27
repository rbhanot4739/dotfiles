local utils = require("config.utils")
local lsp_symbols = LazyVim.config.kind_filter.default
table.insert(lsp_symbols, "Constant")

local M = {}
local exclude_patterns = { "__pycache__", "*.typed" }

local function enable_dash()
  if vim.fn.argc(-1) > 0 then
    return false
  end
  for _, arg in ipairs(vim.v.argv) do
    if arg:sub(1, 1) == "+" then
      return false
    end
  end
  return true
end

---@param picker snacks.Picker
local function switch_to_grep(picker, _)
  local snacks = require("snacks")
  local cwd = picker.input.filter.cwd
  local picker_type = picker.opts.source
  local allowed_pickers = { "files", "buffers", "recent", "smart", "grep", "git_grep", "grep_buffers" }

  if not vim.tbl_contains(allowed_pickers, picker_type) then
    Snacks.notify.warn("Switching to grep is not supported for `" .. picker_type .. "`", { title = "Snacks Picker" })
    return
  end

  if vim.tbl_contains({ "grep", "git_grep", "grep_buffers" }, picker_type) then
    local pattern = picker.input.filter.search or ""

    if picker_type == "grep_buffers" then
      ---@diagnostic disable-next-line: missing-fields
      M.grep_alt_picker = "buffers"
    else
      M.grep_alt_picker = M.grep_alt_picker or "files"
    end
    snacks.picker(M.grep_alt_picker, { cwd = cwd, pattern = pattern })
  else
    local pattern = picker.input.filter.pattern or ""
    if picker_type == "recent_files" then
      picker_type = "recent"
    end
    if picker_type == "buffers" then
      snacks.picker.grep_buffers({ search = pattern })
    else
      local grep_picker = snacks.git.get_root() and "git_grep" or "grep"
      snacks.picker(grep_picker, { cwd = cwd, search = pattern })
    end
    M.grep_alt_picker = picker_type
  end
  picker:close()
end

local function escape_pattern(str, pattern, replace, n)
  pattern = string.gsub(pattern, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
  replace = string.gsub(replace, "[%%]", "%%%%") -- escape replacement

  return string.gsub(str, pattern, replace, n)
end

local function sess_picker(opts)
  local persisted = require("persisted")
  local utils = require("persisted.utils")
  local config = require("persisted.config")

  opts = opts or {}
  Snacks.picker.pick({
    title = "Select Session",
    finder = function()
      local sep = utils.dir_pattern()
      local sessions = persisted.list()
      local res = {}
      for _, session in ipairs(sessions) do
        local session_name = escape_pattern(session, config.save_dir, "")
          :gsub("%%", sep)
          :gsub(vim.fn.expand("~"), sep)
          :gsub("//", "")
          :sub(1, -5)

        local branch, dir_path, dir_name
        if string.find(session_name, "@@", 1, true) then
          local splits = vim.split(session_name, "@@", { plain = true })
          branch = table.remove(splits, #splits)
          dir_path = vim.fn.join(splits, "@@")
        else
          dir_path = session_name
        end

        local dir_parts = vim.fn.split(dir_path, "/")
        dir_name = dir_parts[#dir_parts]

        table.insert(res, {
          file = session,
          text = session,
          branch = branch,
          dir_path = dir_path,
          dir_name = dir_name,
        })
      end
      return res
    end,
    format = function(item, picker)
      local ret = {} ---@type snacks.picker.Highlight[]
      local a = Snacks.picker.util.align
      local icon, icon_hl = "  ", nil
      ret[#ret + 1] = { a(icon, 4), icon_hl }
      ret[#ret + 1] = { a(item.dir_path, 80, { truncate = true }) }
      ret[#ret + 1] = { "    " }
      if item.branch then
        ret[#ret + 1] = { a(" " .. item.branch, 30), "Number" }
      else
        ret[#ret + 1] = { a(" ", 30) }
      end
      return ret
    end,
    layout = opts.layout or {
      preview = false,
      layout = {
        backdrop = false,
        width = 0.7,
        min_width = 80,
        height = 0.5,
        min_height = 3,
        box = "vertical",
        border = "rounded",
        title = "{title}",
        title_pos = "center",
        { win = "input", height = 1, border = "bottom" },
        { win = "list", border = "none" },
        { win = "preview", title = "{preview}", height = 0.4, border = "top" },
      },
    },
    confirm = function(picker, item)
      local session_name = item.text
      persisted.load({ session = session_name })
    end,
    actions = {
      delete = function(picker, item)
        local session_name = item.text
        vim.fn.delete(session_name)
        picker:find()
      end,
    },
    win = {
      input = {
        keys = {
          ["<c-d>"] = { "delete", mode = { "i", "n" } },
        },
      },
    },
  })
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    {
      "<leader>qs",
      function()
        sess_picker()
      end,
    },
    { "<leader>e", false },
    { "<leader>gd", false },
    {
      "<leader>,",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Open recent files",
    },
    {
      "<leader>Z",
      function()
        Snacks.picker.zoxide()
      end,
      desc = "Open zoxide",
    },
    {
      "?",
      function()
        Snacks.picker.lines()
      end,
      desc = "Fuzzy find current word",
    },
    {
      "<leader>/",
      function()
        Snacks.picker.search_history({ layout = { preset = "dropdown", preview = false } })
      end,
      desc = "Fuzzy find files",
    },
    {
      "<leader>=",
      function()
        Snacks.picker.spelling({
          layout = {
            preset = "select",
            layout = {
              relative = "cursor",
              width = 30,
              min_width = 0,
              row = 1,
            },
          },
        })
      end,
      desc = "Spell suggest",
    },
    {
      "<leader>fe",
      function()
        Snacks.explorer({ cwd = vim.fn.expand("%:h") })
      end,
      desc = "Explorer Snacks",
    },
    {
      "<leader>fE",
      function()
        Snacks.explorer({ cwd = vim.uv.cwd() })
      end,
      desc = "Explorer Snacks (cwd)",
    },
    {
      "<leader>fa",
      function()
        Snacks.picker.files({ ignored = true, cwd = vim.fn.expand("%:p:h") })
      end,
      desc = "Find adjacent files",
    },
    {
      "<leader>fP",
      function()
        require("snacks").picker.pick("files", {
          cwd = vim.fn.stdpath("data")[1] or vim.fn.stdpath("data"),
          cmd = "fd",
          args = { "--type", "f", ".lua$" },
        })
      end,
      desc = "Find Plugin files",
    },
    {
      "<leader>sa",
      function()
        Snacks.picker.grep({ ignored = true, cwd = vim.fn.expand("%:p:h") })
      end,
      desc = "Grep adjacent files",
    },
    {
      "<leader>sb",
      function()
        Snacks.picker.pickers()
      end,
      desc = "Snacks builtin pickers",
    },
    {
      "<leader>sb",
      function()
        Snacks.picker.pickers()
      end,
      desc = "Snacks builtin pickers",
    },
    {
      "<leader>sc",
      function()
        Snacks.picker.colorschemes()
      end,
      desc = "Search color scheme",
    },
    -- grep mappings
    { "<leader>sw", LazyVim.pick("grep_word"), desc = "Grep Visual selection or word (Root Dir)", mode = { "n", "x" } },
    {
      "<leader>sW",
      function()
        Snacks.picker.pick("grep_word", { cwd = Snacks.git.get_root() })
      end,
      desc = "Grep Visual selection or word (Git root)",
      mode = { "n", "x" },
    },
    {
      "<leader>sG",
      function()
        Snacks.picker.grep({ cwd = vim.uv.cwd() })
      end,
      desc = "Grep Cwd",
    },
    {
      "<leader>sg",
      function()
        local root_dir = Snacks.git.get_root() ~= nil and Snacks.git.get_root() or LazyVim.root()
        Snacks.picker.grep({ cwd = root_dir })
      end,
      desc = "Grep project root or git root",
    },
    {
      "<leader>ss",
      function()
        Snacks.picker.lsp_symbols({})
      end,
      desc = "LSP Symbols",
    },
    {
      "<leader>SS",
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = "LSP Workspace Symbols",
    },
    {
      "<leader><space>",
      function()
        Snacks.picker.smart()
      end,
      desc = "Smart Picker",
    },
    -- git
    {
      "<leader>gb",
      function()
        Snacks.picker.git_branches({ layout = "ivy" })
      end,
      desc = "Git branches",
    },
    {
      "<leader>gc",
      function()
        Snacks.picker.git_log({ current_line = true })
      end,
      desc = "Git log Current file",
    },
    {
      "<leader>gy",
      function()
        local start_line, end_line
        start_line, end_line = require("utils").get_visual_selection()
        local get_url = function(link_type, copy)
          local l_url = ""
          copy = copy == nil and true or false
          ---@diagnostic disable-next-line: missing-fields
          local opts = {
            notify = false,
            line_start = start_line or nil,
            line_end = end_line or nil,
            what = link_type,
          }
          if copy then
            opts["open"] = function(url)
              l_url = url
              vim.fn.setreg("+", url)
            end
          end
          Snacks.gitbrowse.open(opts)
          return l_url
        end

        local picker = Snacks.picker.pick({
          title = "Select link type",
          items = {
            { text = "repo", preview = { text = get_url("repo") } },
            { text = "branch", preview = { text = get_url("branch") } },
            { text = "file", preview = { text = get_url("file") } },
            { text = "commit", preview = { text = get_url("commit") } },
            { text = "permalink", preview = { text = get_url("permalink") } },
          },
          preview = "preview",
          layout = {
            layout = {
              backdrop = false,
              width = 0.3,
              min_width = 80,
              height = 0.3,
              min_height = 3,
              box = "vertical",
              border = "rounded",
              title = "{title}",
              title_pos = "center",
              { win = "input", height = 1, border = "bottom" },
              { win = "list", border = "none" },
              { win = "preview", title = "{preview}", height = 0.4, border = "top" },
            },
          },
          format = "text",
          ---@param picker snacks.Picker
          confirm = function(picker, item)
            picker:close()
            ---@diagnostic disable-next-line: missing-fields
            get_url(item.text, false)
            return true
          end,
          actions = {
            copy_link = function(picker, item)
              picker:close()
              local url = get_url(item.text)
              Snacks.notify(
                string.format("Copied %s url ( %s ) to clipboard", item.text, url),
                { title = "Git Browse" }
              )
            end,
          },
          win = {
            input = {
              keys = {
                ["<S-Cr>"] = { "copy_link", desc = "Copy link", mode = { "i", "n" } },
              },
            },
          },
        })
        picker:show()
      end,
      mode = { "n", "x" },
      desc = "Git links",
    },
    {
      "<M-/>",
      mode = { "n", "t", "i" },
      function()
        local ft = vim.bo.filetype
        local ft_cmds = { python = "ipython", lua = "lua" }
        if ft == "snacks_terminal" then
          vim.cmd("close")
        else
          Snacks.terminal.toggle(ft_cmds[ft], { interactive = false })
        end
      end,
      desc = "Toggle floating terminal",
    },
    {
      "<c-\\>",
      mode = { "t" },
      function()
        Snacks.terminal.toggle(nil, { win = { style = "split" } })
      end,
      ft = "snacks_terminal",
      desc = "Toggle terminal",
    },
  },
  opts = {
    -- explorer = { enabled = false },
    picker = {
      -- ui_select = true,
      matcher = { frecency = true },
      actions = {
        switch_grep_files = switch_to_grep,
        cd_up = function(picker, _)
          picker:set_cwd(vim.fs.dirname(picker:cwd()))
          local dir = utils.trim_path(picker:cwd())
          picker.title = utils.title(picker.opts.source) .. " (" .. dir .. ")"
          picker:find()
        end,
        focus_to_cwd = function(picker, _)
          picker:set_cwd(vim.uv.cwd())
          picker:find()
        end,
      },
      ---@class snacks.picker.previewers.Config
      previewers = {
        diff = {
          builtin = false, -- use Neovim for previewing diffs (true) or use an external tool (false)
          cmd = { "delta" }, -- example to show a diff with delta
        },
        git = {
          builtin = false, -- use Neovim for previewing git output (true) or use git (false)
          -- args = { "-c", "delta" }, -- additional arguments passed to the git command. Useful to set pager options usin `-c ...`
        },
      },
      layouts = {
        ivy = {
          layout = {
            box = "vertical",
            backdrop = false,
            row = -1,
            width = 0,
            height = 0.4,
            border = "top",
            title = " {title} {live} {flags}",
            title_pos = "center",
            { win = "input", height = 1, border = "bottom" },
            {
              box = "horizontal",
              { win = "list", border = "none" },
              { win = "preview", title = "{preview}", width = 0.65, border = "left" },
            },
          },
        },
        ivy_split = {
          preview = "main",
          layout = {
            box = "vertical",
            backdrop = true,
            width = 0,
            height = 0.2,
            position = "bottom",
            border = "top",
            title = " {title} {live} {flags}",
            title_pos = "center",
            { win = "input", height = 1, border = "bottom" },
            {
              box = "horizontal",
              { win = "list", border = "none" },
              { win = "preview", title = "{preview}", width = 0.6, border = "left" },
            },
          },
        },
      },
      sources = {
        todo_comments = {
          hidden = false,
          ignored = false,
        },
        explorer = {
          supports_live = true,
          cycle = true,
          layout = { preview = "main" },
          exclude = { "*dist-info*", "*.so", "*.pth", "*egg*", "*typed" },
          win = {
            list = {
              keys = {
                ["."] = { "focus_to_cwd", desc = "Focus cwd", mode = { "n" } },
                ["@"] = { "explorer_focus", desc = "Focus selected", mode = { "n" } },
              },
            },
          },
        },
        smart = {
          filter = { cwd = true },
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "n" } },
                ["<m-u>"] = { "cd_up", desc = "cd_up", mode = { "i", "n" } },
              },
            },
          },
        },
        recent = {
          filter = { cwd = true },
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "n" } },
              },
            },
          },
        },
        buffers = {
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "n" } },
              },
            },
          },
        },
        grep_buffers = {
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "n" } },
              },
            },
          },
        },
        files = {
          exclude = exclude_patterns,
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "n" } },
                ["<m-u>"] = { "cd_up", desc = "cd_up", mode = { "i", "n" } },
              },
            },
          },
        },
        grep = {
          exclude = exclude_patterns,
          cwd = require("snacks").git.get_root() ~= nil and require("snacks").git.get_root() or LazyVim.root(),
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to files", mode = { "i", "n" } },
                ["<m-u>"] = { "cd_up", desc = "cd_up", mode = { "i", "n" } },
              },
            },
          },
        },
        git_grep = {
          exclude = exclude_patterns,
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to files", mode = { "i", "n" } },
                ["<m-u>"] = { "cd_up", desc = "cd_up", mode = { "i", "n" } },
              },
            },
          },
        },
        lsp_workspace_symbols = {
          layout = "ivy",
          actions = {
            switch_to_ws = function(picker, item)
              picker:close()
              local pattern = picker.input.filter.search or ""
              Snacks.picker.lsp_symbols({ pattern = pattern })
            end,
          },
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_to_ws", desc = "Switch to workspace symbols", mode = { "i", "n" } },
              },
            },
          },
        },
        lsp_references = {
          -- supports_live = true,
          -- live = false,
        },
        lsp_symbols = {
          -- layout = { preset = "sidebar", layout = { position = "right" } },
          filter = { default = lsp_symbols },
          actions = {
            switch_to_ws = function(picker, _)
              picker:close()
              local pattern = picker.input.filter.pattern or ""
              Snacks.picker.lsp_workspace_symbols({ search = pattern })
            end,
          },
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_to_ws", desc = "Switch to workspace symbols", mode = { "i", "n" } },
              },
            },
          },
        },
        git_log = {
          toggles = {
            current_file = "cf",
            current_line = "cl",
          },
          confirm = function(picker, item)
            local commit = item.commit
            require("diffview")
            local filename = vim.api.nvim_buf_get_name(picker.finder.filter.current_buf)
            -- local cmd = "DiffviewOpen " .. commit .. "^! " .. " -- " .. filename
            local cmd = "DiffviewOpen " .. commit
            vim.print(cmd)
            vim.cmd(cmd)
          end,
          actions = {
            switch_git_log_mode = function(picker, _)
              if not picker.opts["current_file"] and not picker.opts["current_line"] then
                picker.opts["current_line"] = true
                -- picker.opts["follow"] = false
              elseif picker.opts["current_line"] then
                picker.opts["current_line"] = false
                picker.opts["current_file"] = true
                -- picker.opts["follow"] = false
              else
                picker.opts["current_line"] = false
                picker.opts["current_file"] = false
                -- picker.opts["follow"] = true
              end
              picker:find()
            end,
          },
          win = {
            input = {
              keys = {
                ["<C-k>"] = { "switch_git_log_mode", desc = "Switch git_log mode", mode = { "i", "n" } },
                ["<S-Cr>"] = { "git_checkout", desc = "Checkout commit", mode = { "i", "n" } },
              },
            },
          },
        },
      },
      formatters = {
        file = {
          filename_first = true, -- display filename before the file path
        },
      },
      icons = {
        kinds = require("config.utils").icons.kinds,
      },
      win = {
        -- input window
        input = {
          keys = {
            ["<TAB>"] = { "list_down", mode = { "i", "n" } },
            ["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
            ["<C-Space>"] = { "select_and_next", mode = { "i", "n" } },
            ["<A-Space>"] = { "select_and_prev", mode = { "i", "n" } },
          },
        },
      },
    },
    indent = { enabled = true },
    scroll = { enabled = true },
    gitbrowse = {
      enabled = true,
      config = function(opts, defaults)
        table.insert(opts.remote_patterns, { "^(https://).+@(.*):(.*)", "%1%2/%3" })
      end,
    },
    dashboard = {
      enabled = true,
      config = function(opts)
        for _, keymap in ipairs(opts.preset.keys) do
          local desc = string.lower(keymap.desc)
          if desc:find("find file") then
            keymap.action = ":lua Snacks.picker.smart()"
          end
          if desc:find("recent files") then
            keymap.action = ":lua Snacks.picker.recent()"
          end
          if desc:find("grep") or desc:find("find text") then
            keymap.action = ":lua Snacks.picker.grep({cwd = vim.uv.cwd()})"
          end
          if desc:find("projects") then
            keymap.action = ":lua Snacks.picker.zoxide()"
          end
        end
      end,
    },
    scratch = {
      win_by_ft = {
        lua = {
          keys = {
            ["source"] = {
              "<cr>",
              function(self)
                local name = "scratch." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ":e")
                Snacks.debug.run({ buf = self.buf, name = name })
              end,
              desc = "Source buffer",
              mode = { "n", "x" },
            },
          },
        },
        python = {
          keys = {
            ["source"] = {
              "<cr>",
              function(self)
                local name = "scratch." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ":e")
                Snacks.debug.run({ buf = self.buf, name = name })
              end,
              desc = "Source buffer",
              mode = { "n", "x" },
            },
          },
        },
      },
    },
    terminal = {
      win = {
        border = "rounded",
      },
      start_insert = true,
    },
    words = {
      enabled = true,
    },
  },
}
