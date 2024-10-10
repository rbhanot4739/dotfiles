local get_preview_opts = function(opts)
  opts = opts or {}
  return {
    type = "float",
    relative = "editor",
    border = "rounded",
    title = "Preview",
    title_pos = "center",
    position = opts.position or { 0, 0 },
    size = opts.size or { width = 0.3, height = 0.7 },
    zindex = 200,
  }
end

local config_utils = require("config.utils")
return {
  "folke/trouble.nvim",
  cmd = { "Trouble" },
  opts = {
    icons = {
      kinds = config_utils.icons.kinds,
    },
    auto_close = true, -- auto close when there are no items
    auto_open = false, -- auto open when there are items
    auto_preview = false, -- automatically open preview when on an item
    auto_refresh = true, -- auto refresh when open
    auto_jump = false, -- auto jump to the item when there's only one
    focus = false, -- Focus the window when opened
    restore = true, -- restores the last location in the list when opening
    follow = true, -- Follow the current item
    indent_guides = false, -- show indent guides
    modes = {
      symbols = { win = { position = "left", size = 0.2 } },
      lsp = {
        mode = "lsp",
        preview = get_preview_opts({ size = { width = 0.4, height = 0.8 } }),
        win = { position = "right", size = 0.25 },
      },
      diagnostics = {
        mode = "diagnostics",
        preview = get_preview_opts({ position = { 0, -2 } }),
      },
    },
  },
  keys = {
    { "<leader>xX", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
    { "<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
  },
}
