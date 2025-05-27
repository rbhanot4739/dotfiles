return {
  {
    "zbirenbaum/copilot.lua",
    enable = true,
    opts = {
      suggestion = {
        enabled = false,
        keymap = {
          accept = "<S-cr>",
        },
      },
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
      model = "claude-3.5-sonnet",
      debug = false,
      provider = "copilot",
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
    -- commit = "f9aa754",
    cmd = { "AvanteToggle" },
    keys = {
      { "<leader>at", "<cmd>AvanteToggle<cr>", desc = "Avante Toggle" },
    },
    opts = {
      selector = {
        provider = "snacks",
        provider_opts = {},
      },
      provider = "copilot",
      auto_suggestions_provider = "copilot",
      copilot = {
        model = "claude-3.5-sonnet", -- your desired model (or use gpt-4o, etc.)
      },
      features = {
        web_search = false,
        project_context = true,
        file_search = true,
      },
      behaviour = {
        auto_suggestions = true,
        ump_result_buffer_on_finish = true,
        auto_focus_on_diff_view = true,
      },
    },
    history = {
      storage_path = vim.fn.stdpath("state") .. "/avante",
    },
    windows = {
      sidebar_header = {
        align = "left",
        rounded = "true",
      },
    },
    dependencies = {
      {
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "zbirenbaum/copilot.lua",
        {
          "MeanderingProgrammer/render-markdown.nvim",
          opts = {
            file_types = { "markdown", "Avante" },
          },
          ft = { "markdown", "Avante" },
        },
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    enabled = true,
    config = function(_, opts)
      opts = {
        extensions = {
          history = {
            enabled = true,
            opts = {
              keymap = "gh",
              save_chat_keymap = "sc",
              auto_save = true,
              expiration_days = 0,
              picker = "snacks",
              auto_generate_title = true,
              title_generation_opts = {
                adapter = nil, -- e.g "copilot"
                model = nil, -- e.g "gpt-4o"
              },
              continue_last_chat = false,
              delete_on_clearing_chat = true,
              dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
              enable_logging = false,
            },
          },
        },
        -- log_level = "TRACE",
        display = {
          chat = {
            show_header_separator = false,
            start_in_insert_mode = true,
            auto_scroll = true,
            show_settings = false,
            intro_message = "",
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
                  -- default = "gpt-4.1",
                },
              },
            })
          end,
        },
        strategies = {
          chat = {
            roles = {
              ---The header name for the LLM's messages
              ---@type string|fun(adapter: CodeCompanion.Adapter): string
              llm = function(adapter)
                return "  CodeCompanion (  " .. adapter.formatted_name .. ")"
              end,

              ---The header name for your messages
              ---@type string
              user = "  " .. (vim.env.USER or "User"),
            },
            keymaps = {
              send = {
                modes = { n = "<C-s>", i = "<C-s>" },
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
            },
          },
        },
      }
      require("codecompanion").setup(opts)
      vim.cmd([[cab cc CodeCompanion]])
    end,
    cmd = { "CodeCompanionHistory" },
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
        desc = "CodeCompanion new chat",
      },
      {
        "<leader>av",
        "<cmd>CodeCompanionChat Add<cr>",
        mode = { "n", "v" },
        desc = "send visual selection to chat",
      },
      {
        "<leader>ah",
        "<cmd>CodeCompanionHistory<cr>",
        mode = { "n" },
        desc = "chat history",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/codecompanion-history.nvim",
      {
        "MeanderingProgrammer/render-markdown.nvim", -- Enhanced markdown rendering
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        ft = { "markdown", "codecompanion" },
        -- opts = {
        --   overrides = {
        --     filetype = {
        --       codecompanion = {
        --         -- render_modes = true,
        --         sign = {
        --           -- enabled = false, -- Turn off in the status column
        --         },
        --       },
        --     },
        --   },
        -- },
      },
    },
  },
}
