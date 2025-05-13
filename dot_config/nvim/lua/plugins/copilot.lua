return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      filetypes = {
        yaml = false,
        markdown = false,
        help = false,
        hgcommit = false,
        svn = false,
        cvs = false,
      },
      -- copilot_model = "claude-3.5-sonnet",
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = false,
    opts = {
      model = "o3-mini",
      debug = false,
      provider = "copilot",
      sticky = {
        "@models Using o3-mini",
        "#files",
      },
      mappings = {
        reset = {
          normal = "<C-x>",
          insert = "<C-x>",
        },
        accept_diff = {
          normal = "<A-y>",
          insert = "<A-yt>",
        },
      },
    },
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    enabled = false,
    build = "make",
    dependencies = {

      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
    opts = {
      selector = {
        --- @alias avante.SelectorProvider "native" | "fzf_lua" | "mini_pick" | "snacks" | "telescope" | fun(selector: avante.ui.Selector): nil
        provider = "snacks",
        -- Options override for custom providers
        provider_opts = {},
      },
      provider = "copilot",
      auto_suggestions_provider = "copilot",
      copilot = {
        model = "claude-3.5-sonnet", -- your desired model (or use gpt-4o, etc.)
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    enabled = true,
    config = function(_, opts)
      opts = {
        display = {
          chat = {
            show_header_separator = true,
            start_in_insert_mode = false,
            window = { height = 0.8, width = 0.35 },
          },
          diff = {
            enabled = true,
            close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
            layout = "vertical", -- vertical|horizontal split for default provider
            opts = {
              "internal",
              "filler",
              "closeoff",
              "algorithm:histogram",
              "followwrap",
              "linematch:120",
              "indent-heuristic",
            },
            provider = "default", -- default|mini_diff
          },
        },
        adapters = {
          copilot = function()
            return require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = {
                  default = "claude-3.5-sonnet",
                },
              },
            })
          end,
        },
        strategies = {
          chat = {
            keymaps = {
              send = {
                modes = { n = "<C-s>", i = "<S-cr>" },
              },
              send_to_smart = {
                modes = { n = "<S-CR>" },
                description = "Send to smart (claude-sonnet)",
                callback = function(chat)
                  chat:apply_model("claude-3.7-sonnet")
                  chat:submit()
                end,
              },
              close = {
                modes = { n = "<C-c>", i = "<C-c>" },
              },
              stop = {
                modes = { n = "<a-x>", i = "<a-x>" },
              },
              -- Add further custom keymaps here
            },
          },
        },
      }
      require("codecompanion").setup(opts)
      vim.cmd([[cab cc CodeCompanion]])
    end,
    keys = {
      {
        "<leader>aa",
        mode = { "n", "v" },
        "<cmd>CodeCompanionChat Toggle<cr>",
        desc = "CodeCompanion Chat",
      },
      {
        "<leader>aq",
        ":CodeCompanion",
        mode = { "n", "x", "v" },
        desc = "CodeCompanion inline chat",
      },
      {
        "<leader>AA",
        "<cmd>CodeCompanionActions<cr>",
        mode = { "n", "v" },
        desc = "CodeCompanion actions",
      },
      {
        "<leader>an",
        "<cmd>CodeCompanionChat<cr>",
        mode = { "n", "v" },
        desc = "CodeCompanion actions",
      },
      {
        "<leader>av",
        "<cmd>CodeCompanionChat Add<cr>",
        mode = { "n", "v" },
        desc = "CodeCompanion actions",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
