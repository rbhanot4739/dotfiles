return {
  {
    "echasnovski/mini.operators",
    opts = {
      -- Exchange text regions
      exchange = {
        -- a pretty neat trick to exchange two args is `gxina` and then press `.`
        prefix = "gx",

        -- Whether to reindent new text to match previous indent
        reindent_linewise = true,
      },
      -- Replace text with register
      replace = {
        prefix = "gr",

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
    version = false,
  },
  {
    "echasnovski/mini.files",
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        mappings = {
          -- go_in = "<Right>",
          -- go_out = "<Left>",
          go_in_plus = "<CR>",
          go_in_horizontal = "-",
          go_in_horizontal_plus = "_",
          go_in_vertical = "\\",
          go_in_vertical_plus = "|",
        },
        windows = {
          preview = true,
          width_nofocus = 20,
          width_focus = 40,
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
        desc = "Explorer Mini.files",
      },
      -- {
      --   "<leader>E",
      --   function()
      --     require("mini.files").open(vim.loop.cwd(), true)
      --   end,
      --   desc = "Open mini.files (cwd)",
      -- },
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
    -- left brackets [{( include the space around the brackets while the right don't
    -- [ -( hello )-] # consider this string
    -- ;d) -> [- hello -]  -- similarly ;r)< changes to [-< hello >-]
    -- ;d( -> [-hello-])  -- similarly ;r(< changes to [-<hello>-]
    "echasnovski/mini.surround",
    opts = {
      mappings = {
        add = ";;",
        delete = ";d",
        replace = ";r",
        find = ";>",
        find_left = ";<",
        highlight = ";h",
        update_n_lines = ";n",
      },
    },
  },
}
