return {
  {
    "zbirenbaum/copilot.lua",
    enable = true,
    opts = {
      suggestion = {
        enabled = true,
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
      model = "claude-opus-4",
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
    cmd = { "AvanteToggle" },
    keys = {
      {
        "<leader>AA",
        function()
          vim.cmd("AvanteClear")
          vim.cmd("AvanteChat")
        end,
        desc = "Avante Clear and Chat",
      },
    },
    opts = {
      selector = {
        provider = "snacks",
        provider_opts = {},
      },
      auto_suggestions_provider = "copilot",
      providers = {
        copilot = {
          -- model = "claude-3.7-sonnet", -- your desired model (or use gpt-4o, etc.)
          model = "claude-opus-4", -- your desired model (or use gpt-4o, etc.)
        },
      },
      -- },
      features = {
        web_search = false,
        project_context = true,
        file_search = true,
      },
      behaviour = {
        auto_suggestions = false,
        enable_cursor_planning_mode = true,
        jump_result_buffer_on_finish = false,
        auto_focus_on_diff_view = false,
        enable_token_counting = false,
      },
      mappings = {
        sidebar = {
          close_from_input = { normal = "q", insert = "<C-d>" },
        },
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
        -- "stevearc/dressing.nvim",
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
        --   -- send_code = false,
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
        --   -- log_level = "TRACE",
        display = {
          chat = {
            start_in_insert_mode = true,
            auto_scroll = true,
            intro_message = "",
            window = { height = 0.8, width = 0.35 },
          },
          diff = {
            opts = {
              "internal",
              "filler",
              "closeoff",
              "algorithm:histogram",
              "followwrap",
              "linematch:120",
              "indent-heuristic",
            },
            provider = "mini_diff", -- default|mini_diff
          },
        },
        adapters = {
          copilot = function()
            return require("codecompanion.adapters").extend("copilot", {
              schema = {
                model = {
                  default = "claude-sonnet-4",
                  -- default = "claude-3.7-sonnet",
                  -- default = "gpt-4.1",
                },
              },
            })
          end,
        },
        strategies = {
          chat = {
            slash_commands = {
              ["git_files"] = {
                description = "List git files",
                ---@param chat CodeCompanion.Chat
                callback = function(chat)
                  local handle = io.popen("git ls-files")
                  if handle ~= nil then
                    local result = handle:read("*a")
                    handle:close()
                    chat:add_reference({ role = "user", content = result }, "git", "<git_files>")
                  else
                    return vim.notify("No git files available", vim.log.levels.INFO, { title = "CodeCompanion" })
                  end
                end,
                opts = {
                  contains_code = true,
                },
              },
            },
            tools = {
              opts = {
                auto_submit_errors = true, -- Send any errors to the LLM automatically?
                auto_submit_success = true, -- Send any successful output to the LLM automatically?
              },
            },
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
                modes = { n = "<S-CR>", i = "<S-CR>" },
                description = "Send to smart (gemini2.5-pro)",
                callback = function(chat)
                  chat:apply_model("gemini-2.5-pro-preview-06-05")
                  chat:submit()
                end,
              },
              close = {
                modes = { n = "q", i = "<C-d>" },
              },
              stop = {
                modes = { n = "<c-c>", i = "<c-c>" },
              },
            },
          },
        },
      }
      require("codecompanion").setup(opts)
      vim.cmd([[cab cc CodeCompanion]])
      vim.cmd([[cab ccc CodeCompanionChat]])
      vim.cmd([[cab cca CodeCompanionActions]])
      vim.cmd([[cab cch CodeCompanionHistory]])
    end,
    cmd = { "CodeCompanionHistory" },
    keys = {
      {
        "<leader>ct",
        mode = { "n", "v" },
        "<cmd>CodeCompanionChat Toggle<cr>",
        desc = "CodeCompanion Chat",
      },
      {
        "<leader>ci",
        ":CodeCompanion",
        mode = { "n", "x", "v" },
        desc = "CodeCompanion inline chat",
      },
      {
        "<leader>CA",
        "<cmd>CodeCompanionActions<cr>",
        mode = { "n", "v" },
        desc = "CodeCompanion actions",
      },
      {
        "<leader>cc",
        "<cmd>CodeCompanionChat<cr>",
        mode = { "n", "v" },
        desc = "CodeCompanion new chat",
      },
      {
        "<leader>cv",
        "<cmd>CodeCompanionChat Add<cr>",
        mode = { "n", "v" },
        desc = "send visual selection to chat",
      },
      {
        "<leader>ch",
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
