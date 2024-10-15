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
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        mappings = {
          go_in = "<Right>",
          go_out = "<Left>",
          go_in_plus = "<Cr>",
        },
        windows = {
          preview = true,
          width_nofocus = 20,
          width_focus = 50,
          width_preview = 80,
        },
        options = {
          use_as_default_explorer = true,
        },
        permanent_delete = false,
      })
    end,
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
        add = ";;",
        delete = ";d",
        find = ";>",
        find_left = ";<",
        highlight = ";h",
        replace = ";r",
        update_n_lines = ";n",
      },
    },
  },
}
