-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.wrap = true
vim.g.lazyvim_python_lsp = "basedpyright"
vim.opt.spell = false
vim.opt.spelllang = { "en_us" }
vim.opt.laststatus = 3
-- vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions,skiprtp"

-- vim.api.nvim_create_autocmd("VimEnter", {
--   group = vim.api.nvim_create_augroup("Persistence", { clear = true }),
--   callback = function()
--     -- NOTE: Before restoring the session, check:
--     -- 1. No arg passed when opening nvim, means no `nvim --some-arg ./some-path`
--     -- 2. No pipe, e.g. `echo "Hello world" | nvim`
--     if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
--       require("persistence").load()
--     end
--   end,
--   -- HACK: need to enable `nested` otherwise the current buffer will not have a filetype(no syntax)
--   nested = true,
-- })
