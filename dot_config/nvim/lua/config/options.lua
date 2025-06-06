-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.wrap = true
vim.g.lazyvim_python_lsp = "basedpyright"
vim.opt.laststatus = 3
vim.o.showtabline = 0
vim.o.cursorlineopt = "number,line"
-- vim.g.snacks_animate = false
vim.g.autoformat = false
vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions,skiprtp"

-- Clipboard https://github.com/LazyVim/LazyVim/discussions/4602#discussioncomment-10995917
if vim.env.SSH_TTY then
  vim.opt.clipboard:append("unnamedplus")
  local function paste()
    return vim.split(vim.fn.getreg(""), "\n")
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
  }
end
vim.o.foldlevelstart = 99
-- vim.o.foldlevelstart = 4
vim.g.ai_cmp = false
vim.opt.diffopt = {
  "internal",
  "filler",
  "closeoff",
  "context:12",
  "algorithm:histogram",
  "linematch:200",
  "indent-heuristic",
}
vim.diagnostic.config({
  -- virtual_text = { current_line = true },
  -- virtual_lines = { current_line = true },
})
