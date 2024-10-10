return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed.
      "nvim-telescope/telescope.nvim", -- optional
      -- "ibhagwan/fzf-lua", -- optional
    },
    -- cmd = "Neogit",
    opts = {
      kind = "auto",
    },
    keys = { { "<leader>gg", "<cmd>Neogit<cr>", desc = "Open Neogit" } },
  },
  {
    "sindrets/diffview.nvim",
    dependencies = {
      {
        "paopaol/telescope-git-diffs.nvim",
        requires = {
          "nvim-lua/plenary.nvim",
          "sindrets/diffview.nvim",
        },
        config = function()
          require("telescope").load_extension("git_diffs")
        end,
      },
    },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Open Diffview" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Open history for current File" },
      { "<leader>gl", "<cmd>Telescope git_diffs  diff_commits<cr>", desc = "Telescope git Log" },
      {
        "q",
        "<cmd>DiffviewClose<CR>",
        ft = { "DiffViewFiles", "DiffviewFileHistory" },
        desc = "`q` to close diff view",
      },
    },
  },
  {
    "linrongbin16/gitlinker.nvim",
    cmd = "GitLink",
    opts = {},
    keys = {
      { "<leader>gy", "<cmd>GitLink<cr>", mode = { "n", "v" }, desc = "Yank git link" },
      { "<leader>gY", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open git link" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
    },
  },
}
