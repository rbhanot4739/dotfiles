-- load simple utility plugins
return {
  {
    "aserowy/tmux.nvim",
    opts = {
      copy_sync = {
        enable = false,
        sync_clipboard = true,
      },
    },
  },
  {
    -- auto add fstrings
    "chrisgrieser/nvim-puppeteer",
    ft = { "python" },
  },
  {
    "okuuva/auto-save.nvim",

    cmd = "ASToggle", -- optional for lazy loading on command
    event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
    opts = {
      write_all_buffers = true,
      trigger_events = { -- See :h events
        immediate_save = { "BufLeave", "FocusLost" }, -- vim events that trigger an immediate save
        defer_save = { "InsertLeave", "TextChanged" }, -- vim events that trigger a deferred save (saves after `debounce_delay`)
        cancel_defered_save = { "InsertEnter" }, -- vim events that cancel a pending deferred save
      },
      debounce_delay = 5000,
      execution_message = {
        enabled = true,
        message = function() -- message to print on save
          return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
        end,
        dim = 0.10, -- dim the color of `message`
        cleaning_interval = 1250, -- (milliseconds) automatically clean MsgArea after displaying `message`. See :h MsgArea
      },
    },
  },
  {
    "chrisgrieser/nvim-spider",
    opts = {},
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
  -- {
  --   "chrisgrieser/nvim-spider",
  --   keys = {
  --     -- { mode = { "n", "o", "x" }, "cw", "c<cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-ce" } },
  --     { mode = { "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Spider-w" } },
  --     { mode = { "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-e" } },
  --     { mode = { "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Spider-b" } },
  --   },
  -- },
  {
    "karb94/neoscroll.nvim",
    opts = {
      easing = "cube",
    },
  },
}
