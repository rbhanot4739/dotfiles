return {
  "folke/flash.nvim",
  opts = {
    jump = {
      autojump = true,
    },
    highlight = {
      -- show a backdrop with hl FlashBackdrop
      backdrop = true,
      -- Highlight the search matches
      matches = true,
    },
    search = {
      -- mode = "fuzzy",
    },
    label = {
      style = "inline",
    },
    modes = {
      search = { enabled = false, highlight = { backdrop = true } },
      char = {
        keys = { "f", "F", "t", "T" },
        jump_labels = true,
        multi_line = false,
        jump = {
          autojump = true,
        },
      },
    },
  },
  keys = {
    {
      "r",
      mode = "o",
      function()
        require("flash").remote()
      end,
      desc = "Remote Flash",
    },

    {
      "R",
      mode = { "o", "x" },
      function()
        require("flash").treesitter_search({
          remote_op = { restore = true, motion = true },
          highlight = {
            backdrop = true,
          },
        })
      end,
      desc = "Remote Treesitter Search",
    },
    -- {
    --   "<leader>**",
    --   mode = "n",
    --   function()
    --     require("flash").jump({ continue = true })
    --   end,
    --   desc = "Flash: Continue last search keyword under cursor",
    -- },
    {
      "<leader>*",
      mode = { "n" },
      function()
        require("flash").jump({ pattern = vim.fn.expand("<cword>") })
      end,
      desc = "Flash: Search word under cursor with flash",
    },
  },
}
