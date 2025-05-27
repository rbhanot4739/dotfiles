return {
  "saghen/blink.cmp",
  event = { "InsertEnter" },
  dependencies = {
    "mikavilpas/blink-ripgrep.nvim",
    -- "rcarriga/cmp-dap",
    "Kaiser-Yang/blink-cmp-git",
    "Kaiser-Yang/blink-cmp-dictionary",
    "Kaiser-Yang/blink-cmp-avante",
    "fang2hou/blink-copilot",
    -- "Exafunction/codeium.nvim",
    {
      "giuxtaposition/blink-cmp-copilot",
      enabled = false,
    },
  },
  -- event = "VeryLazy",
  opts = {
    keymap = {
      preset = "enter",
      ["<Tab>"] = {
        -- function(cmp)
        --   if cmp.snippet_active() then
        --     return cmp.accept()
        --   else
        --     return cmp.select_next()
        --   end
        --   if require("copilot.suggestion").is_visible() then
        --     require("copilot.suggestion").accept()
        --   else
        --     return cmp.select_next()
        --   end
        -- end,
        "select_next",
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
        ghost_text = { enabled = true },
        list = {
          selection = { preselect = false, auto_insert = true },
        },
        menu = {
          auto_show = true,
        },
      },
    },
    completion = {
      ghost_text = {
        enabled = true,
      },
      trigger = {
        show_on_blocked_trigger_characters = {},
        show_in_snippet = false,
      },
      menu = {
        -- min_width = 10,
        -- max_height = 10,
        -- border = "rounded",
        draw = {
          -- columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
        },
        auto_show = function(ctx)
          return vim.bo.filetype ~= "markdown"
        end,
      },
      documentation = { window = { border = "rounded" } },
    },
    signature = { enabled = true, window = { border = "rounded" } },
    fuzzy = {
      sorts = {
        function(a, b)
          local sort = require("blink.cmp.fuzzy.sort")
          if a.source_id == "spell" and b.source_id == "spell" then
            return sort.label(a, b)
          end
        end,
        -- This is the normal default order, which we fall back to
        "score",
        "kind",
        "label",
      },
    },
    sources = {
      default = {
        "dictionary",
        "markdown",
        "ripgrep",
        "avante",
        -- "codeium",
        -- "dap",
      },
      providers = {
        codeium = { name = "Codeium", module = "codeium.blink", async = true },
        copilot = {
          async = true,
          score_offset = 100,
          module = "blink-copilot",
          -- override = {
          --   get_trigger_characters = function(self)
          --     local trigger_characters = self:get_trigger_characters()
          --     vim.list_extend(trigger_characters, { "\n", "\t", " " })
          --     return trigger_characters
          --   end,
          -- },
        },
        lsp = {
          async = true,
          score_offset = 99,
          override = {
            get_trigger_characters = function(self)
              local trigger_characters = self:get_trigger_characters()
              vim.list_extend(trigger_characters, { "\n", "\t", " " })
              return trigger_characters
            end,
          },
        },
        buffer = { enabled = false, score_offset = 98 },
        path = {
          score_offset = 95,
          enabled = function()
            return not vim.tbl_contains({ "copilot-chat", "codecompanion", "AvanteInput" }, vim.bo.filetype)
            -- return vim.bo.filetype ~= "copilot-chat" and vim.bo.filetype ~= "codecompanion"
          end,
        },
        dictionary = {
          module = "blink-cmp-dictionary",
          name = "Dict",
          min_keyword_length = 3,
          opts = {
            dictionary_files = { vim.fn.expand("~/words.txt") },
            get_documentation = function()
              return nil
            end,
          },
        },
        ripgrep = {
          module = "blink-ripgrep",
          name = "Ripgrep",
          score_offset = 90,
          opts = {
            prefix_min_len = 5,
            context_size = 3,
          },
          transform_items = function(_, items)
            for _, item in ipairs(items) do
              -- example: append a description to easily distinguish rg results
              item.labelDetails = {
                description = "(rg)",
              }
            end
            return items
          end,
        },
        markdown = {
          name = "RenderMarkdown",
          module = "render-markdown.integ.blink",
          fallbacks = { "lsp" },
        },
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
        avante = {
          module = "blink-cmp-avante",
          name = "Avante",
          opts = {
            -- options for blink-cmp-avante
          },
        },
      },
    },
  },
}
