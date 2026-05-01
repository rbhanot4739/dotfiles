local function toggle_diffview_cmd(cmd)
  if next(require("diffview.lib").views) ~= nil then
    vim.cmd("DiffviewClose")
    return
  end

  vim.cmd(cmd)
end

local function git_repo_root()
  local file_dir = vim.fn.expand("%:p:h")
  if file_dir == "" then
    file_dir = vim.fn.getcwd()
  end

  local out = vim.fn.systemlist({ "git", "-C", file_dir, "rev-parse", "--show-toplevel" })
  if vim.v.shell_error == 0 and out[1] and out[1] ~= "" then
    return out[1]
  end

  out = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })
  if vim.v.shell_error == 0 and out[1] and out[1] ~= "" then
    return out[1]
  end

  return nil
end

local function git_ref_exists(root, ref)
  vim.fn.system({ "git", "-C", root, "rev-parse", "--verify", ref })
  return vim.v.shell_error == 0
end

local function resolve_base_ref(root)
  local out = vim.fn.systemlist({ "git", "-C", root, "symbolic-ref", "--quiet", "--short", "refs/remotes/origin/HEAD" })
  if vim.v.shell_error == 0 and out[1] and out[1] ~= "" then
    local origin_head = out[1]
    if git_ref_exists(root, origin_head) then
      return origin_head
    end
  end

  local candidates = { "origin/main", "origin/master", "main", "master" }
  for _, ref in ipairs(candidates) do
    if git_ref_exists(root, ref) then
      return ref
    end
  end

  return nil
end

local function repo_relative_path(root, abs_path)
  local norm_root = vim.fs.normalize(root)
  local norm_abs = vim.fs.normalize(abs_path)
  local prefix = norm_root .. "/"

  if norm_abs:sub(1, #prefix) == prefix then
    return norm_abs:sub(#prefix + 1)
  end

  return nil
end

local function git_path_has_uncommitted_changes(root, rel_path)
  local out = vim.fn.systemlist({ "git", "-C", root, "status", "--porcelain", "--", rel_path })
  return vim.v.shell_error == 0 and #out > 0
end

local function git_path_has_pr_changes(root, base, rel_path)
  vim.fn.system({ "git", "-C", root, "diff", "--quiet", base .. "...HEAD", "--", rel_path })
  return vim.v.shell_error == 1
end

local function toggle_diffview_for_current_file()
  if next(require("diffview.lib").views) ~= nil then
    vim.cmd("DiffviewClose")
    return
  end

  local abs_path = vim.fn.expand("%:p")
  if abs_path == "" then
    vim.notify("Diffview: no current file", vim.log.levels.WARN)
    return
  end

  local escaped_path = vim.fn.fnameescape(abs_path)
  local root = git_repo_root()
  if not root then
    toggle_diffview_cmd("DiffviewOpen -- " .. escaped_path)
    return
  end

  local rel_path = repo_relative_path(root, abs_path)
  if not rel_path then
    vim.notify("Diffview: current file is outside git root", vim.log.levels.WARN)
    return
  end

  if git_path_has_uncommitted_changes(root, rel_path) then
    toggle_diffview_cmd("DiffviewOpen -- " .. escaped_path)
    return
  end

  local base = resolve_base_ref(root)
  if base and git_path_has_pr_changes(root, base, rel_path) then
    toggle_diffview_cmd("DiffviewOpen " .. base .. "...HEAD -- " .. escaped_path)
    return
  end

  vim.notify("Diffview: no changes for current file", vim.log.levels.INFO)
end

local function toggle_diffview_pr_style_against_default()
  local root = git_repo_root()
  if not root then
    vim.notify("Diffview: not inside a git repository", vim.log.levels.WARN)
    return
  end

  local base = resolve_base_ref(root)
  if not base then
    vim.notify("Diffview: could not find base branch (origin/main, origin/master, main, master)", vim.log.levels.WARN)
    return
  end

  toggle_diffview_cmd("DiffviewOpen " .. base .. "...HEAD")
end

local function toggle_diffview_against_default()
  if next(require("diffview.lib").views) ~= nil then
    vim.cmd("DiffviewClose")
    return
  end

  local actions = require("diffview.actions")
  actions.diff_against_default_branch()
end

return {
  {
    "dlyongemallo/diffview.nvim",
    version = "*",
    cmd = {
      "DiffviewOpen",
      "DiffviewFileHistory",
      "DiffviewDiffFiles",
      "DiffviewClose",
      "DiffviewFocusFiles",
      "DiffviewToggleFiles",
      "DiffviewRefresh",
    },
    -- cond = require("utils").is_git_worktree,
    config = function()
      local actions = require("diffview.actions")
      require("diffview").setup({
        enhanced_diff_hl = true,
        watch_index = true,
        hide_merge_artifacts = true,
        large_file_threshold = 4000,
        persist_selections = { enabled = true },
        diffopt = {
          algorithm = "histogram",
          indent_heuristic = true,
          linematch = 60,
        },
        view = {
          default = {
            layout = "diff2_horizontal",
            disable_diagnostics = false,
            winbar_info = false,
            focus_diff = true,
          },
          merge_tool = {
            layout = "diff3_mixed",
            disable_diagnostics = false,
            winbar_info = false,
            focus_diff = true,
          },
          file_history = {
            layout = "diff2_horizontal",
            disable_diagnostics = true,
            winbar_info = false,
            focus_diff = true,
          },
          foldlevel = 0,
          cycle_layouts = {
            default = { "diff2_horizontal", "diff2_vertical", "diff1_inline" },
            merge_tool = { "diff3_mixed", "diff3_horizontal", "diff3_vertical", "diff4_mixed", "diff1_plain" },
          },
          inline = { style = "unified" },
        },
        file_panel = {
          listing_style = "tree",
          mark_placement = "sign_column",
          show_branch_name = true,
          win_config = {
            position = "left",
            width = 35,
          },
        },
        keymaps = {
          view = {
            {
              "n",
              "q",
              function()
                vim.cmd("DiffviewClose")
              end,
              { desc = "Close Diffview" },
            },
          },
          file_panel = {
            {
              "n",
              "q",
              function()
                vim.cmd("DiffviewClose")
              end,
              { desc = "Close Diffview" },
            },
          },
          file_history_panel = {
            {
              "n",
              "q",
              function()
                vim.cmd("DiffviewClose")
              end,
              { desc = "Close Diffview" },
            },
          },
          option_panel = {
            {
              "n",
              "q",
              function()
                vim.cmd("DiffviewClose")
              end,
              { desc = "Close Diffview" },
            },
          },
          help_panel = {
            {
              "n",
              "q",
              function()
                vim.cmd("DiffviewClose")
              end,
              { desc = "Close Diffview" },
            },
            {
              "n",
              "<esc>",
              function()
                vim.cmd("DiffviewClose")
              end,
              { desc = "Close Diffview" },
            },
          },
        },
      })
    end,
    keys = {
      {
        "<leader>gdh",
        function()
          toggle_diffview_cmd("DiffviewOpen")
        end,
        desc = "WIP diff against HEAD",
      },
      {
        "<leader>gdu",
        function()
          toggle_diffview_against_default()
        end,
        desc = "Diff against upstream base tip",
      },
      {
        "<leader>gdp",
        function()
          toggle_diffview_pr_style_against_default()
        end,
        desc = "PR-style diff against base",
      },
      {
        "<leader>gdf",
        function()
          toggle_diffview_for_current_file()
        end,
        desc = "Diff current file (WIP, else PR-style)",
      },
      {
        "<leader>gf",
        function()
          toggle_diffview_cmd("DiffviewFileHistory %")
        end,
        desc = "Open file history",
      },
    },
  },
  { "gitsigns.nvim", opts = {} },
}
