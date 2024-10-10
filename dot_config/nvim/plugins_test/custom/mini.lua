return {
  {
    "echasnovski/mini.operators",
    version = false,
    opts = {
      -- Exchange text regions
      exchange = {
        prefix = "gX",

        -- Whether to reindent new text to match previous indent
        reindent_linewise = true,
      },
      -- Replace text with register
      replace = {
        prefix = "gp", -- p as in put/paste

        -- Whether to reindent new text to match previous indent
        reindent_linewise = true,
      },

      -- Sort text
      sort = {
        prefix = "gS",

        -- Function which does the sort
        func = nil,
      },
    },
  },
  {
    "echasnovski/mini.files",
    opts = {
      -- mappings = {
      --   go_in = "<Right>",
      --   go_out = "<Left>",
      -- },
      windows = {
        preview = true,
        width_nofocus = 20,
        width_focus = 50,
        width_preview = 100,
      },
      options = {
        use_as_default_explorer = true,
      },
    },
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = "Open mini.files (directory of current file)",
      },
      {
        "<leader>E",
        function()
          require("mini.files").open(vim.loop.cwd(), true)
        end,
        desc = "Open mini.files (cwd)",
      },
      {
        "<leader>fm",
        function()
          require("mini.files").open(LazyVim.root(), true)
        end,
        desc = "Open mini.files (root)",
      },
    },
  },
  {
    "echasnovski/mini.surround",
    opts = {
      mappings = {
        add = "gs",
      },
    },
  },
}
