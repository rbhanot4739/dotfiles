return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  lazy = true,
  keys = {
    {
      "<M-Up>",
      mode = { "n", "v" },
      function()
        require("multicursor-nvim").addCursor("k")
      end,
      desc = "Add cursor above",
    },
    {
      "<M-Down>",
      mode = { "n", "v" },
      function()
        require("multicursor-nvim").addCursor("j")
      end,
      desc = "Add cursor below",
    },
    {
      "<M-n>",
      mode = { "n", "v" },
      function()
        require("multicursor-nvim").matchAddCursor(1)
      end,
      desc = "Add cursor to next match",
    },
    {
      "<M-N>",
      mode = { "n", "v" },
      function()
        require("multicursor-nvim").matchSkipCursor(1)
      end,
      desc = "Do not add cursor to next match",
    },
    {
      "<M-p>",
      mode = { "n", "v" },
      function()
        require("multicursor-nvim").matchAddCursor(-1)
      end,
    },
    {
      "<M-P>",
      mode = { "n", "v" },
      function()
        require("multicursor-nvim").matchSkipCursor(-1)
      end,
    },
    {
      mode = "n",
      "<A-\\>",
      function()
        require("multicursor-nvim").alignCursors()
      end,
    },
    {
      mode = "v",
      "I",
      function()
        require("multicursor-nvim").insertVisual()
      end,
    },
    {
      mode = "v",
      "A",
      function()
        require("multicursor-nvim").appendVisual()
      end,
    },
    {
      "<M-x>",
      mode = "n",
      function()
        if not require("multicursor-nvim").cursorsEnabled() then
          require("multicursor-nvim").enableCursors()
        elseif require("multicursor-nvim").hasCursors() then
          require("multicursor-nvim").clearCursors()
        else
          -- Default <esc> handler.
        end
      end,
      desc = "Close cursors",
    },
  },
  opts = {},
}
