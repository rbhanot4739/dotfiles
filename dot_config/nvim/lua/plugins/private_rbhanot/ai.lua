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
    "NickvanDyke/opencode.nvim",
    dependencies = { "folke/snacks.nvim" },
    ---@type opencode.Config
    opts = {
      -- Your configuration, if any
    },
  -- stylua: ignore
  keys = {
    { '<leader>ot', function() require('opencode').toggle() end, desc = 'Toggle embedded opencode', },
    { '<leader>oa', function() require('opencode').ask('@cursor: ') end, desc = 'Ask opencode', mode = 'n', },
    { '<leader>oa', function() require('opencode').ask('@selection: ') end, desc = 'Ask opencode about selection', mode = 'v', },
    { '<leader>op', function() require('opencode').select_prompt() end, desc = 'Select prompt', mode = { 'n', 'v', }, },
    { '<leader>oo', function() require('opencode').command('session_new') end, desc = 'New session', },
    { '<leader>oy', function() require('opencode').command('messages_copy') end, desc = 'Copy last message', },
    { '<S-C-u>',    function() require('opencode').command('messages_half_page_up') end, desc = 'Scroll messages up', },
    { '<S-C-d>',    function() require('opencode').command('messages_half_page_down') end, desc = 'Scroll messages down', },
  },
  },
}
