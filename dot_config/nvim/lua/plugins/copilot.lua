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
      copilot_model =  "claude-3.5-sonnet",
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = true,
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
              "indent-heuristic"
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
                modes = { n = "q", i = "<C-c>" },
              },
              -- Add further custom keymaps here
            },
          },
        },
      }
      require("codecompanion").setup(opts)
      local keymap = vim.keymap
      keymap.set({ "n", "v" }, "<leader>AA", "<cmd>CodeCompanionActions<cr>")
      keymap.set({ "n", "v" }, "<leader>aq", ":CodeCompanion ")
      keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>")
      keymap.set({ "n", "v" }, "<leader>an", "<cmd>CodeCompanionChat<cr>")
      keymap.set({ "n", "v" }, "<leader>av", "<cmd>CodeCompanionChat Add<cr>")
      vim.cmd([[cab cc CodeCompanion]])
    end,
    -- keys = {
    --   {
    --     "<leader>aa",
    --     function()
    --       require("codecompanion").toggle()
    --     end,
    --     desc = "CodeCompanion Chat",
    --   },
    --   {
    --     "<leader>aq",
    --     "<cmd>CodeCompanion<cr>",
    --     mode = { "n", "x", "v" },
    --     desc = "CodeCompanion inline chat",
    --   },
    --   {
    --     "<leader>AA",
    --     function()
    --       require("codecompanion").actions()
    --     end,
    --     mode = { "n", "v" },
    --     desc = "CodeCompanion actions",
    --   },
    -- },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
