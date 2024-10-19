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
      debounce_delay = 2000,
    },
  },
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {
      easing = "cube",
    },
  },
  {
    "otavioschwanck/arrow.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
    opts = {
      show_icons = true,
      leader_key = ";", -- Recommended to be a single key
      buffer_leader_key = "m", -- Per Buffer Mappings
    },
  },
  -- Session mgmt plugins
  {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
      suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
      use_git_branch = true,
      cwd_change_handling = true,
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
  -- {
  --   "olimorris/persisted.nvim",
  --   lazy = false, -- make sure the plugin is always loaded at startup
  --   config = function(_, opts)
  --     local persisted = require("persisted")
  --     persisted.branch = function()
  --       local branch = vim.fn.systemlist("git branch --show-current")[1]
  --       return vim.v.shell_error == 0 and branch or nil
  --     end
  --     persisted.setup(opts)
  --     require("telescope").setup({
  --       extensions = {
  --         persisted = {
  --           -- layout_config = { width = 0.55, height = 0.40 },
  --         },
  --       },
  --     })
  --     require("telescope").load_extension("persisted")
  --     vim.api.nvim_create_autocmd("User", {
  --       pattern = "PersistedTelescopeLoadPre",
  --       callback = function(session)
  --         -- Save the currently loaded session using the global variable
  --         require("persisted").save({ session = vim.g.persisted_loaded_session })
  --
  --         -- Delete all of the open buffers
  --         vim.api.nvim_input("<ESC>:silent! %bd!<CR>")
  --       end,
  --     })
  --   end,
  --   opts = {
  --     autoload = true,
  --     use_git_branch = true,
  --     on_autoload_no_session = function()
  --       vim.notify("No existing session to load.")
  --     end,
  --     ignored_dirs = { "~/.config", "~/.local", { "~/", exact = true } },
  --   },
  -- },
  -- {
  --   "echasnovski/mini.sessions",
  --   version = false,
  --   config = function()
  --     require("mini.sessions").setup({ autoread = true, verbose = { read = true, write = true, delete = true } })
  --   end,
  -- },
  -- {
  --   "Bekaboo/deadcolumn.nvim",
  --   opts = {
  --     mode = { "n", "i", "v" },
  --     warning = {
  --       alpha = 0.4,
  --       colorcode = "#FF0000",
  --       hlgroup = { "Error", "bg" },
  --     },
  --   },
  -- },
}
