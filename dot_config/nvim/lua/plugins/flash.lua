return {
  "folke/flash.nvim",
  opts = {
    jump = { autojump = true }, -- automatically jump when there is only one match
    modes = {
      char = {
        keys = { "f", "F", "t", "T" },
        -- add labels to fF and tT commands
        jump_labels = true,
      },
      search = {
        enabled = false,
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
          remote_op = {
            restore = true,
            motion = true,
          },
        })
      end,
      desc = "Remote Treesitter Search",
    },
    {
      ",,",
      mode = "n",
      function()
        require("flash").jump({ continue = true })
      end,
      desc = "Flash: Continue last search keyword under cursor",
    },
    {
      ",",
      mode = { "n" },
      function()
        require("flash").jump({ pattern = vim.fn.expand("<cword>") })
      end,
      desc = "Flash: Search word under cursor with flash",
    },
  },
}
