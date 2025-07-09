vim.g.python3_host_prog = vim.fn.expand("~") .. "/.nvim-env/bin/python"
-- Set git editor for nvim-remote
if vim.fn.has("nvim") == 1 then
  vim.env.GIT_EDITOR = "nvr -cc split --remote-wait"
end

-- Auto-delete git buffers when hidden
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "gitcommit", "gitrebase", "gitconfig" },
  command = "set bufhidden=delete",
})

require("config.lazy")
