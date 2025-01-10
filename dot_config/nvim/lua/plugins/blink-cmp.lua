return {
  "saghen/blink.cmp",
  dependencies = {
    "mikavilpas/blink-ripgrep.nvim",
    "rcarriga/cmp-dap",
    "saghen/blink.compat",
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
      -- ["<C-k>"] = { "select_prev", "fallback" },
      -- ["<C-j>"] = { "select_next", "fallback" },
      ["<S-up>"] = { "scroll_documentation_up", "fallback" },
      ["<S-down>"] = { "scroll_documentation_down", "fallback" },
    },
    appearance = {
      kind_icons = require("config.utils").icons.kinds,
    },
    completion = {
      -- list = {
      --   selection = function(ctx)
      --     return ctx.mode == "cmdline" and "manual" or "manual"
      --   end,
      -- },
      menu = { border = "rounded" },
      documentation = { window = { border = "rounded" } },
    },
    signature = { enabled = true, window = { border = "rounded" } },
    sources = {
      compat = {},
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
        "markdown",
        "ripgrep",
        -- "dap",
      },
      cmdline = function()
        local type = vim.fn.getcmdtype()
        -- Search forward and backward
        if type == "/" or type == "?" then
          return { "buffer" }
        end
        -- Commands
        if type == ":" then
          return { "cmdline" }
        end
        return {}
      end,
      providers = {
        -- copilot = { score_offset = 100 },
        -- lsp = { async = true, score_offset = 1 },
        -- buffer = { score_offset = 2 },
        -- path = { score_offset = 3 },
        ripgrep = {
          module = "blink-ripgrep",
          name = "Ripgrep",
          score_offset = 95,
        },
        markdown = { name = "RenderMarkdown", module = "render-markdown.integ.blink" },
        dap = {
          name = "dap",
          module = "blink.compat.source",
          enabled = function()
            require("cmp_dap").is_dap_buffer()
          end,
        },
      },
    },
  },
}
