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
