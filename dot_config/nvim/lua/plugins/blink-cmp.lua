return {
  "saghen/blink.cmp",
  dependencies = {
    "mikavilpas/blink-ripgrep.nvim",
  },
  opts = {
    keymap = {
      preset = "enter",
      ["<Tab>"] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.accept()
          else
            return cmp.select_next()
          end
        end,
        "snippet_forward",
        "fallback",
      },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<S-up>"] = { "scroll_documentation_up", "fallback" },
      ["<S-down>"] = { "scroll_documentation_down", "fallback" },
      -- ["<Esc>"] = { "hide", "fallback" },
      ["<C-e>"] = { "cancel", "fallback" },
    },
    appearance = {
      kind_icons = require("config.utils").icons.kinds
    },
    sources = {
      compat = {},
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
        'markdown',
        "ripgrep",
      },
      providers = {
        ripgrep = {
          module = "blink-ripgrep",
          name = "Ripgrep",
        },
        markdown = { name = 'RenderMarkdown', module = 'render-markdown.integ.blink' },
      },
    },
    signature = { enabled = true },
  },
}
