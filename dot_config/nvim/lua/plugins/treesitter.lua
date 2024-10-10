return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
  init = function() end,
  opts = {
    textobjects = {
      swap = {
        enable = true,
        swap_next = { ["<leader>sp"] = "@parameter.inner" },
        swap_previous = { ["<leader>sP"] = "@parameter.inner" },
      },
    },
  },
}
