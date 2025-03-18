return {

  {
    "gbprod/yanky.nvim",
    opts = { textobj = {
      enabled = true,
    } },
    keys = {
      { "<leader>p", false },
      {
        "p",
        mode = { "o", "x" },
        function()
          require("yanky.textobj").last_put()
        end,
        desc = "text object for last put",
      },
      {
        "<c-r>",
        mode = { "i" },
        function()
          Snacks.picker.yanky()
        end,
        desc = "Paste yank ring",
      },
      {
        "<leader>p",
        function()
          Snacks.picker.yanky()
        end,
        { desc = "Open Yank history" },
      },
      { "P", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Selection" },
      { "p", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put Text After Selection" },
      { "gp", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put Text After Cursor" },
      { "gP", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Cursor" },
    },
  },
}
