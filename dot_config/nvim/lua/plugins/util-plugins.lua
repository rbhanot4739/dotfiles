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
  -- Todo: Assess if I really need this, as I could not seem to fit this into my workflow
  {
    "otavioschwanck/arrow.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
    keys = {
      {
        "m",
        function()
          require("arrow.buffer_ui").openMenu()
        end,
        noremap = true,
        silent = true,
        nowait = true,
        desc = "Arrow File Mappings",
      },
      {
        ",",
        function()
          require("arrow.ui").openMenu()
        end,
        noremap = true,
        silent = true,
        nowait = true,
        desc = "Arrow Buffer Mappings",
      },
    },
    lazy = true,
    opts = {
      show_icons = true,
      leader_key = ",", -- Recommended to be a single key
      buffer_leader_key = "m", -- Per Buffer Mappings
    },
  },
  -- Quickfix
  {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {
      follow = {
        enabled = true,
      },
    },
    keys = {
      {
        ">",
        function()
          require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
        end,
        desc = "Expand quickfix context",
      },
      {
        "<",
        function()
          require("quicker").collapse()
        end,
        desc = "Collapse quickfix context",
      },
    },
  },
  -- Session mgmt
  {
    "olimorris/persisted.nvim",
    event = "BufReadPre", -- Ensure the plugin loads only when a buffer has been loaded
    cmd = { "SessionSelect", "SessionLoad" },
    opts = {
      use_git_branch = true,
      autosave = true,
      on_autoload_no_session = function()
        vim.notify("No existing session to load.")
      end,
    },
    config = function(_, opts)
      local persisted = require("persisted")
      persisted.branch = function()
        local branch = vim.fn.systemlist("git branch --show-current")[1]
        return vim.v.shell_error == 0 and branch or nil
      end
      persisted.setup(opts)
    end,
  },
  -- {
  --   "rmagatti/auto-session",
  --   lazy = false,
  --   enabled = false,
  --   keys = {
  --     { "<leader>qs", [[<cmd>SessionSearch<cr>]], desc = "SessionSearch" },
  --   },
  --   opts = {
  --     bypass_save_filetypes = { "alpha", "dashboard", "snacks_dashboard" },
  --     suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
  --     use_git_branch = true,
  --     cwd_change_handling = true,
  --     auto_restore = false,
  --     session_lens = {
  --       theme_conf = {
  --         border = true,
  --         layout_config = {
  --           width = 0.8, -- Can set width and height as percent of window
  --           height = 0.5,
  --         },
  --       },
  --     },
  --   },
  -- },

  -- https://github.com/glacambre/firenvim
  { "glacambre/firenvim", build = ":call firenvim#install(0)" },
  {
    "chrisgrieser/nvim-rip-substitute",
    cmd = "RipSubstitute",
    opts = {
      keymaps = { abort = "<Esc>", toggleIgnoreCase = "<C-i>" },
      popupWin = { position = "top" },
    },
    keys = {
      {
        "<leader>?",
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
