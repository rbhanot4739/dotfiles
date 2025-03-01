return {
  "saghen/blink.cmp",
  dependencies = {
    "mikavilpas/blink-ripgrep.nvim",
    -- "rcarriga/cmp-dap",
    "Kaiser-Yang/blink-cmp-git",
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
    cmdline = {
      enabled = true,
      sources = function()
        local type = vim.fn.getcmdtype()
        if type == "/" or type == "?" then
          return { "buffer" }
        end
        if type == ":" or type == "@" then
          return { "cmdline" }
        end
        return {}
      end,
      completion = {
        trigger = {
          show_on_blocked_trigger_characters = {},
          show_on_x_blocked_trigger_characters = nil, -- Inherits from top level `completion.trigger.show_on_blocked_trigger_characters` config when not set
        },
        menu = {
          auto_show = nil, -- Inherits from top level `completion.menu.auto_show` config when not set
          draw = {},
        },
      },
    },
    completion = {
      menu = {
        -- min_width = 10,
        -- max_height = 10,
        -- border = "rounded",
        draw = {
          -- columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } }
        },
      },
      documentation = { window = { border = "rounded" } },
    },
    signature = { enabled = true, window = { border = "rounded" } },
    sources = {
      default = {
        "lsp",
        "path",
        "snippets",
        "buffer",
        "markdown",
        "ripgrep",
        -- "dap",
      },
      providers = {
        copilot = { async = true, score_offset = 100 },
        lsp = { async = true, score_offset = 99 },
        buffer = { score_offset = 98 },
        -- path = { score_offset = 97 },
        ripgrep = {
          module = "blink-ripgrep",
          name = "Ripgrep",
          score_offset = 97,
        },
        markdown = { name = "RenderMarkdown", module = "render-markdown.integ.blink" },
        dap = {
          name = "dap",
          module = "blink.compat.source",
          enabled = function()
            require("cmp_dap").is_dap_buffer()
          end,
        },
        git = {
          module = "blink-cmp-git",
          name = "Git",
          enabled = function()
            return vim.tbl_contains({ "octo", "gitcommit", "markdown" }, vim.bo.filetype)
          end,
        },
      },
    },
  },
}
