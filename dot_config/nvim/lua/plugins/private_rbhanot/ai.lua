return {
  {
    "folke/sidekick.nvim",
    opts = {
      cli = {
        mux = {
          enabled = true,
          backend = "tmux", -- or "tmux"
        },
      },
    },
    keys = {
      {
        "<leader>av",
        function()
          require("sidekick.cli").send({ msg = "{selection}" })
        end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>ac",
        function()
          require("sidekick.cli").toggle({ name = "cursor", focus = true })
        end,
        desc = "Sidekick Cursor Toggle",
      },
      {
        "<leader>ao",
        function()
          require("sidekick.cli").toggle({ name = "opencode", focus = true })
        end,
        desc = "Sidekick Opencode Toggle",
      },
    },
  },

  {
    "zbirenbaum/copilot.lua",
    enable = false,
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
    "NickvanDyke/opencode.nvim",
    dependencies = { "folke/snacks.nvim" },
    ---@type opencode.Config
    opts = {
      -- Your configuration, if any
    },
  -- stylua: ignore
  keys = {
    { '<leader>ot', function() require('opencode').toggle() end, desc = ' Opencode - Toggle', },
    { '<leader>oa', function() require('opencode').ask('@cursor: ') end, desc = ' Opencode - Ask', mode = 'n', },
    { '<leader>oa', function() require('opencode').ask('@selection: ') end, desc = ' Opencode - Ask about selection', mode = 'v', },
    { '<leader>op', function() require('opencode').select_prompt() end, desc = ' Opencode - Select prompt', mode = { 'n', 'v', }, },
    { '<leader>oo', function() require('opencode').command('session_new') end, desc = ' Opencode - New session', },
    { '<leader>oy', function() require('opencode').command('messages_copy') end, desc = ' Opencode - Copy last message', },
    { '<S-C-u>',    function() require('opencode').command('messages_half_page_up') end, desc = ' Opencode - Scroll  up', },
    { '<S-C-d>',    function() require('opencode').command('messages_half_page_down') end, desc = ' Opencode - Scroll down', },
  },
  },
}
