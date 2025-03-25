-- local function is_git_root()
--   return require("snacks").git.get_root() ~= nil
-- end

local is_git_root = require("utils").is_git_worktree

local function toggle_diffview(cmd)
  if next(require("diffview.lib").views) == nil then
    vim.cmd(cmd)
  else
    vim.cmd("DiffviewClose")
  end
end

return {
  {
    "pwntester/octo.nvim",
    opts = {
      picker = "snacks",
      picker_config = {
        use_emojis = false, -- only used by "fzf-lua" picker for now
        mappings = {
          open_in_browser = { lhs = "<C-b>", desc = "open issue in browser" },
          copy_url = { lhs = "<C-y>", desc = "copy url to system clipboard" },
          checkout_pr = { lhs = "<C-o>", desc = "checkout pull request" },
          merge_pr = { lhs = "<C-r>", desc = "merge pull request" },
        },
      },
    },
    cond = is_git_root,
    keys = function()
      return {
        {
          "<leader>gp",
          "<cmd>Octo pr create<cr>",
          desc = "Create new PR",
        },
        { "<leader>gP", "<cmd>Octo pr list<cr>", desc = "List PRs" },
      }
    end,
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration
    },
    cond = is_git_root,
    enabled = false,
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
    -- cond = is_git_root,
    config = function()
      local actions = require("diffview.actions")
      require("diffview").setup({
        enhanced_diff_hl = true,
        view = {
          merge_tool = {
            layout = "diff3_mixed",
            disable_diagnostics = false,
            winbar_info = false,
          },
          file_history = {
            layout = "diff2_horizontal",
            disable_diagnostics = true,
            winbar_info = true,
          },
        },
        keymaps = {
          view = {
            { "n", "q", actions.close, { desc = "Close help menu" } },
          },
          file_panel = {
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close help menu" } },
          },
          file_history_panel = {
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close help menu" } },
          },
        },
      })
    end,
    keys = {
      {
        "<leader>gd",
        function()
          toggle_diffview("DiffviewOpen")
        end,
        desc = "Diff Index",
      },
      {
        "<leader>gD",
        function()
          toggle_diffview("DiffviewOpen master..HEAD")
        end,
        desc = "Diff master",
      },
      {
        "<leader>gf",
        function()
          toggle_diffview("DiffviewFileHistory %")
        end,
        desc = "Open diffs for current File",
      },
      -- {
      --   "q",
      --   "<cmd>DiffviewClose<CR>",
      --   ft = { "DiffviewFiles", "DiffviewFileHistory" },
      --   desc = "`q` to close diff view",
      -- },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    cond = is_git_root,
    opts = {
      current_line_blame = true,
    },
  },
}
