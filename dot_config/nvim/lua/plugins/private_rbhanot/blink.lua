return {
  "saghen/blink.cmp",
  dependencies = {
    "mikavilpas/blink-ripgrep.nvim",
    -- "rcarriga/cmp-dap",
    "Kaiser-Yang/blink-cmp-git",
    "Kaiser-Yang/blink-cmp-dictionary",
    "fang2hou/blink-copilot",
  },
  opts = {
    keymap = {
      preset = "enter",
      ["<Tab>"] = {
        -- function() -- sidekick next edit suggestion
        --   return require("sidekick").nes_jump_or_apply()
        -- end,
        -- function() -- if you are using Neovim's native inline completions
        --   return vim.lsp.inline_completion.get()
        -- end,
        "select_next",
        "snippet_forward",
        "fallback",
      },
      ["<S-cr>"] = {
        function()
          return vim.lsp.inline_completion.get()
        end,
      },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<S-up>"] = { "scroll_documentation_up", "fallback" },
      ["<S-down>"] = { "scroll_documentation_down", "fallback" },
      -- ["<Esc>"] = { "hide", "fallback" },
    },
    appearance = {
      kind_icons = require("config.utils").icons.kinds,
    },
    completion = {
      trigger = {
        show_in_snippet = false,
      },
      accept = {
        -- experimental auto-brackets support
        auto_brackets = {
          enabled = false,
        },
      },
    },
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
      },
      per_filetype = {
        codecompanion = {
          "codecompanion",
          "buffer",
          "dictionary",
        },
      },
      providers = {
        -- copilot = {
        --   async = true,
        --   score_offset = 100,
        --   module = "blink-copilot",
        --   override = {
        --     get_trigger_characters = function(self)
        --       local trigger_characters = self:get_trigger_characters()
        --       vim.list_extend(trigger_characters, { "\n", "\t", " " })
        --       return trigger_characters
        --     end,
        --   },
        -- },
        snippets = {
          score_offset = 100,
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
        buffer = { opts = { enable_in_ex_commands = true } },
        ripgrep = {
          module = "blink-ripgrep",
          name = "Ripgrep",
          score_offset = 97,
          opts = {
            backend = {
              context_size = 3,
            },
            prefix_min_len = 5,
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
        path = {
          score_offset = 96,
          enabled = function()
            return not vim.tbl_contains({ "copilot-chat", "codecompanion", "AvanteInput" }, vim.bo.filetype)
          end,
        },
        dictionary = {
          module = "blink-cmp-dictionary",
          name = "Dict",
          score_offset = 90,
          min_keyword_length = 5,
          opts = {
            dictionary_files = { vim.fn.expand("~/words.txt") },
            get_documentation = function()
              return nil
            end,
          },
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
      },
    },
  },
}
