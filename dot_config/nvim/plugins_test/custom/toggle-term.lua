return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup()
      vim.keymap.set(
        { "n", "t", "i" },
        "",
        "<cmd>ToggleTerm direction=horizontal size=25<cr>",
        { desc = "Toggle terminal" }
      )
    end,
  },
}
