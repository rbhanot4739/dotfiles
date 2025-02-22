is_git_worktree = require("utils").is_git_worktree

return {
  {
    "pwntester/octo.nvim",
    opts = {
      picker = "snacks",
    },
    keys = function()
      return {
        { "<leader>gp", "<cmd>Octo pr create<cr>", desc = "Create new PR" },
        { "<leader>gP", "<cmd>Octo pr list<cr>", desc = "List PRs" },
      }
    end,
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration
      -- "nvim-telescope/telescope.nvim", -- optional
    },
    cmd = "Neogit",
    opts = {
      kind = "split",
      initial_branch_name = "rbhanot/",
      log_view = {
        kind = "split",
      },
      mappings = {
        status = {
          ["up"] = "PeekUp",
          ["down"] = "PeekDown",
        },
      },
    },
    keys = {
      { "<leader>gG", "<cmd>Neogit<cr>", desc = "Neogit" },
      -- {
      --   "<leader>gc",
      --   function()
      --     require("neogit").action("log", "log_current", { "--author", "rbhanot" })()
      --   end,
      --   desc = "My Commits",
      -- },
      -- {
      --   "<leader>gl",
      --   function()
      --     require("neogit").action("log", "log_current")()
      --   end,
      --   desc = "Neogit log",
      -- },
      -- {
      --   "<leader>gp",
      --   function()
      --     require("neogit").action("pull", "from_upstream")()
      --   end,
      --   desc = "Pull from upstreame",
      -- },
    },
  },
  {
    "sindrets/diffview.nvim",
    command = "DiffviewOpen",
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diff Index" },
      { "<leader>gD", "<cmd>DiffviewOpen master..HEAD<CR>", desc = "Diff master" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Open diffs for current File" },
      -- { "<leader>gL", "<cmd>Telescope git_diffs  diff_commits<cr>", desc = "Telescope git Log" },
      {
        "q",
        "<cmd>DiffviewClose<CR>",
        ft = { "DiffviewFiles", "DiffviewFileHistory" },
        desc = "`q` to close diff view",
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
    },
  },
}
