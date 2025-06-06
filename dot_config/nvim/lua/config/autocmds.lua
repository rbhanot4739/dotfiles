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

vim.api.nvim_create_autocmd("User", {
  pattern = "BlinkCmpMenuOpen",
  callback = function()
    vim.b.copilot_suggestion_hidden = true
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "BlinkCmpMenuClose",
  callback = function()
    vim.b.copilot_suggestion_hidden = false
  end,
})
