is_git_worktree = require("utils").is_git_worktree

return {
  {
    "pwntester/octo.nvim",
    keys = function()
      return { { "<leader>go", "<cmd>Octo<cr>", desc = "Open Octo" } }
    end,
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration
      "nvim-telescope/telescope.nvim", -- optional
    },
    cmd = "Neogit",
    opts = {
      kind = "split",
    },
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
      {
        "<leader>gc",
        function()
          require("neogit").action("log", "log_current", { "--author", "rbhanot" })()
        end,
        desc = "My Commits",
      },
      {
        "<leader>gl",
        function()
          require("neogit").action("log", "log_current")()
        end,
        desc = "Neogit log",
      },
      {
        "<leader>gp",
        function()
          require("neogit").action("pull", "from_upstream")()
        end,
        desc = "Pull from upstreame",
      },
    },
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
    command = "DiffviewOpen",
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diff Index" },
      { "<leader>gD", "<cmd>DiffviewOpen HEAD..master<CR>", desc = "Diff master" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Open diffs for current File" },
      { "<leader>gL", "<cmd>Telescope git_diffs  diff_commits<cr>", desc = "Telescope git Log" },
      {
        "q",
        "<cmd>DiffviewClose<CR>",
        ft = { "DiffviewFiles", "DiffviewFileHistory" },
        desc = "`q` to close diff view",
      },
    },
  },
  {
    "linrongbin16/gitlinker.nvim",
    cmd = "GitLink",
    opts = {},
    keys = {
      { "<leader>gY", "<cmd>GitLink<cr>", mode = { "n", "v" }, desc = "Yank git link" },
      { "<leader>gy", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open git link" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
    },
  },
}
