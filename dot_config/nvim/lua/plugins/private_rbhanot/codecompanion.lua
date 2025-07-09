return {
  "olimorris/codecompanion.nvim",
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
  enabled = true,
  config = function(_, opts)
    opts = {
      send_code = false,
      prompt_library = {
        ["Create a PR"] = {
          strategy = "chat",
          description = "Create a PR with the current changes",
          opts = {
            index = 10,
            short_name = "pr",
            is_default = true,
            is_slash_cmd = true,
            auto_submit = true,
            modes = { "n", "v" },
          },
          prompts = {
            {
              role = "system",
              content = "You are an expert at Git and following the Conventional Commit specifications.",
            },
            {
              role = "user",
              content = function()
                vim.g.codecompanion_auto_tool_mode = true
                return [[
### Instructions

#### Important Constraints
- **CRITICAL**: Do not perform any actions if the currently checked out branch is `main` or `master`.
- Ensure all git operations are safe and reversible.


#### Step 1: Commit Message Generation
  Please generate a commit message for the changes in the current git repository. Follow these rules:
  - If the current branch is not in sync with the remote tracking branch, notify the user and exit.
  - If there are only unstaged changes, notify the user and exit without making any changes.
  - If there are both staged and unstaged changes, only include the staged changes in the commit.
  - If there is nothing to commit, proceed with the pull request creation step.

    The commit message should:
    - Be concise, clear, and explain the changes being introduced in the diff
    - Follow the conventional commit format (e.g., `feat:`, `fix:`, `docs:`, etc.)
    - Be suitable for a pull request
    - 

    Use the @{cmd_runner} tool to:
    1. Run appropriate git commands to get the staged changes
    2. Generate an appropriate commit message based on the diff
    3. Commit the changes with the generated message

#### Step 2: Pull Request Creation/Update

- Compare the current branch with `main` or `master` and if there are no new commits, notify the user and exit.
- If there are new commits, proceed to create or update a pull request:
  - If the current branch is not pushed to the remote repository, push it first.
  - If no pull request exists, create a new one with the generated title and body.
  - If a pull request already exists for the current branch:
    - If there are no new commits since last PR notify the user and exit.
    - If there are new commits, update the PR body with the generated commit message by just appending it to the existing body.

Use the @{cmd_runner} tool to run `gh` CLI commands with the following logic:
- If the `gh` CLI is not installed, notify the user and exit
- If the `gh` CLI is installed, check if the current branch is already pushed to the remote repository

**Pull Request Title**: Derive from the commit message body and ensure it's clear and concise

**Pull Request Body**: Follow this exact template:

```md
## Problem & Solution Overview

### Why 

### What 

## Testing Done

```

- **Why section**: Explain the problem that the changes are solving (e.g., Bugfix, Feature, Enhancement, etc.)
- **What section**: Explain what specific changes were made to solve the problem
- **Testing Done section**: Explain how the changes were tested and what tests were created/updated

]]
              end,
              opts = {
                contains_code = false,
              },
            },
          },
        },
      },
      extensions = {
        ["chat-model-toggle"] = {
          opts = {
            keymap = "gm", -- Model picker keymap
          },
        },
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
          -- provider = "mini_diff", -- default|mini_diff
        },
      },
      adapters = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                default = "claude-sonnet-4",
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          opts = { completion_provider = "blink" },
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
              description = "Send to smart (claude-3.7-sonnet-thought)",
              callback = function(chat)
                -- chat:apply_model("gemini-2.5-pro-preview-06-05")
                chat:apply_model("claude-3.7-sonnet-thought")
                chat:submit()
              end,
            },
            close = {
              modes = { n = "Q", i = "<C-d>" },
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
  cmd = { "CodeCompanionHistory", "CodeCompanion" },
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
}
