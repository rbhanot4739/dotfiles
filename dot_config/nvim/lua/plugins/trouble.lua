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
    modes = {
      symbols = {
        desc = "document symbols",
        mode = "lsp_document_symbols",
        focus = true,
        win = { position = "right", size = 50 },
        format = "{kind_icon} {symbol.name}",
        filter = {
          ["not"] = { ft = "lua", kind = "Package" },
          any = {
            -- all symbol kinds for help / markdown files
            ft = { "help", "markdown" },
            -- default set of symbol kinds
            kind = {
              "Class",
              "Constant",
              "Constructor",
              "Enum",
              "Field",
              "Function",
              "Interface",
              "Method",
              "Module",
              "Namespace",
              "Package",
              "Property",
              "Struct",
              "Trait",
            },
          },
        },
      },
      --   diagnostics = {
      --     mode = "diagnostics",
      --     preview = get_preview_opts({ position = { 0, -2 } }),
      --   },
    },
  },
  keys = {
    { "<leader>XX", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
    { "<leader>xx", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
  },
}
