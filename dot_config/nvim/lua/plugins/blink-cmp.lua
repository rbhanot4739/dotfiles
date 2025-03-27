return {
  "saghen/blink.cmp",
  dependencies = {
    "mikavilpas/blink-ripgrep.nvim",
    -- "rcarriga/cmp-dap",
    "Kaiser-Yang/blink-cmp-git",
    "Kaiser-Yang/blink-cmp-avante",
    "ribru17/blink-cmp-spell",
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
        list = {
          selection = { preselect = false, auto_insert = true },
        },
        menu = {
          auto_show = true,
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
          -- columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
        },
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
        "markdown",
        "ripgrep",
        "spell",
        -- "dap",
      },
      providers = {
        copilot = { async = true, score_offset = 100 },
        lsp = { async = true, score_offset = 99 },
        buffer = { enabled = false, score_offset = 98 },
        path = {
          score_offset = 95,
          enabled = function()
            return vim.bo.filetype ~= "copilot-chat"
          end,
        },
        ripgrep = {
          module = "blink-ripgrep",
          name = "Ripgrep",
          score_offset = 97,
          opts = {
            backend = "gitgrep-or-ripgrep",
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
        spell = {
          name = "Spell",
          module = "blink-cmp-spell",
          opts = {
            -- EXAMPLE: Only enable source in `@spell` captures, and disable it
            -- in `@nospell` captures.
            enable_in_context = function()
              local curpos = vim.api.nvim_win_get_cursor(0)
              local captures = vim.treesitter.get_captures_at_pos(0, curpos[1] - 1, curpos[2] - 1)
              local in_spell_capture = false
              for _, cap in ipairs(captures) do
                if cap.capture == "spell" then
                  in_spell_capture = true
                elseif cap.capture == "nospell" then
                  return false
                end
              end
              return in_spell_capture
            end,
          },
        },
        avante = {
          module = "blink-cmp-avante",
          name = "Avante",
          opts = {
            -- options for blink-cmp-avante
          },
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
