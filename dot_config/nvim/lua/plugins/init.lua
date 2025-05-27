-- Plugin configuration imports
-- This file imports all individual plugin configurations from rbhanot subdirectory

return {
  -- Core functionality
  require("plugins.rbhanot.util-plugins"),
  require("plugins.rbhanot.which-key"),
  require("plugins.rbhanot.mini"),
  require("plugins.rbhanot.snacks"),
  require("plugins.rbhanot.flash"),
  require("plugins.rbhanot.yank"),

  -- UI and appearance
  require("plugins.rbhanot.colorscheme"),
  require("plugins.rbhanot.lualine"),
  require("plugins.rbhanot.edgy"),
  require("plugins.rbhanot.noice"),

  -- File navigation and search
  -- require("plugins.rbhanot.telescope"),
  -- require("plugins.rbhanot.fzf"),

  -- Code editing and completion
  require("plugins.rbhanot.treesitter"),
  require("plugins.rbhanot.lsp"),
  require("plugins.rbhanot.blink-cmp"),
  require("plugins.rbhanot.nvim-cmp"),
  require("plugins.rbhanot.multi-cursors"),

  -- Development tools
  require("plugins.rbhanot.debugger"),
  require("plugins.rbhanot.neotest"),
  require("plugins.rbhanot.git"),
  require("plugins.rbhanot.trouble"),
  require("plugins.rbhanot.todo-comments"),

  -- Language and environment specific
  require("plugins.rbhanot.ai"),
  require("plugins.rbhanot.venv-selector"),
  require("plugins.rbhanot.markdown"),

  -- Terminal and window management
  require("plugins.rbhanot.term"),
  require("plugins.rbhanot.smart-split"),
}
