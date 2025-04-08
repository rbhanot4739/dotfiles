local formatOpts = vim.api.nvim_create_augroup("FormatOpts", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
  group = formatOpts,
  pattern = "*",
  callback = function()
    vim.opt.formatoptions:remove({ "r", "o" })
    -- vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Enable autoformat for specific filetypes
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "lua", "markdown" },
  callback = function()
    vim.b.autoformat = true
  end,
})

local visual_mode_group = vim.api.nvim_create_augroup("VisualModeGroup", { clear = true })

local function send_keys(keys)
  return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), "n", false)
end
-- go to beginning of line when exiting visual mode
vim.api.nvim_create_autocmd("ModeChanged", {
  group = visual_mode_group,
  -- Only trigger when going from visual to normal mode, not visual to command mode
  pattern = { "v:n", "V:n", "\22:n" }, -- Use raw escape code for ^V
  callback = function()
    -- Ensure we're not in command mode
    if vim.fn.mode() ~= "n" then
      return
    end

    vim.schedule(function()
      -- Double check we're in normal mode
      if vim.fn.mode() ~= "n" then
        return
      end

      local up_end = vim.fn.line("'<")
      local down_end = vim.fn.line("'>")
      local curr = vim.fn.line(".")

      if curr == up_end then
        send_keys("`>")
      elseif curr == down_end then
        send_keys("`<")
      end
    end)
  end,
})
