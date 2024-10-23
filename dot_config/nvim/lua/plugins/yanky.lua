return {
  "gbprod/yanky.nvim",
  enabled = not vim.env.SSH_TTY,
  keys = {
    { "[P", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Selection" },
    { "]P", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put Text After Selection" },
  },
}
