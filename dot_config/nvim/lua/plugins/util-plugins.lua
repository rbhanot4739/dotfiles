-- load simple utility plugins
return {
  {
    "okuuva/auto-save.nvim",

    cmd = "ASToggle", -- optional for lazy loading on command
    event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
    opts = {
      write_all_buffers = true,
      trigger_events = { -- See :h events
        immediate_save = { "BufLeave", "FocusLost" }, -- vim events that trigger an immediate save
        defer_save = { "InsertLeave", "TextChanged" }, -- vim events that trigger a deferred save (saves after `debounce_delay`)
        cancel_deferred_save = { "InsertEnter" }, -- vim events that cancel a pending deferred save
      },
      debounce_delay = 1000,
    },
  },
  {
    "otavioschwanck/arrow.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
    opts = {
      show_icons = true,
      leader_key = "\\", -- Recommended to be a single key
      buffer_leader_key = "m", -- Per Buffer Mappings
    },
  },
  -- Session mgmt plugins
  {
    "rmagatti/auto-session",
    lazy = false,
    enabled = true,
    keys = {
      { "<leader>qs", [[<cmd>SessionSearch<cr>]], desc = "SessionSearch" },
    },
    opts = {
      bypass_save_filetypes = { "alpha", "dashboard", "snacks_dashboard" },
      suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      use_git_branch = true,
      cwd_change_handling = true,
      auto_restore = true,
      session_lens = {
        theme_conf = {
          border = true,
          layout_config = {
            width = 0.8, -- Can set width and height as percent of window
            height = 0.5,
          },
        },
      },
    },
  },
  {
    "chrisgrieser/nvim-rip-substitute",
    cmd = "RipSubstitute",
    opts = {
      keymaps = { abort = "<Esc>" },
    },
    keys = {
      {
        "<leader>:",
        function()
          require("rip-substitute").sub()
        end,
        mode = { "n", "x" },
        desc = " rip substitute",
      },
    },
  },
  {
    "chrisgrieser/nvim-spider",
    opts = {
      -- skipInsignificantPunctuation = true,
    },
    keys = {
      {
        "w",
        "<cmd>lua require('spider').motion('w')<CR>",
        mode = { "n", "o", "x" },
        desc = "Move to end of word",
      },
      {
        "e",
        "<cmd>lua require('spider').motion('e')<CR>",
        mode = { "n", "o", "x" },
        desc = "Move to start of next word",
      },
      {
        "b",
        "<cmd>lua require('spider').motion('b')<CR>",
        mode = { "n", "o", "x" },
        desc = "Move to start of previous word",
      },
    },
  },
}
