-- local formatOpts = vim.api.nvim_create_augroup("FormatOpts", { clear = true })
-- vim.api.nvim_create_autocmd("BufEnter", {
--   group = formatOpts,
--   pattern = "*",
--   callback = function()
--     vim.opt.formatoptions:remove({ "c", "r", "o" })
--   end,
-- })
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "python", "json" },
  callback = function()
    vim.b.autoformat = false
  end,
  once = true,
})
