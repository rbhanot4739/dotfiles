return {
  "ThePrimeagen/refactoring.nvim",
  keys = {
    {
      "<leader>rs",
      require("refactoring").select_refactor,
      mode = { "n", "x", "v" },
      desc = "refactors",
    },
  },
}
