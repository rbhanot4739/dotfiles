return {
  "ThePrimeagen/refactoring.nvim",
  keys = {
    {
      "<leader>rr",
      function()
        require("telescope").extensions.refactoring.refactors()
      end,
      { "n", "x" },
    },
  },
}
