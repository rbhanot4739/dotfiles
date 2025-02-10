return {

  {
    "gbprod/yanky.nvim",
    opts = { textobj = {
      enabled = true,
    } },
    keys = {
      {
        "p",
        mode = { "o", "x" },
        function()
          require("yanky.textobj").last_put()
        end,
        desc = "text object for last put",
      },
      { "P", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Selection" },
      { "p", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put Text After Selection" },
      { "gp", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put Text After Cursor" },
      { "gP", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Cursor" },
    },
  },
}
