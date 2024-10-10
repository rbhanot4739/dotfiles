local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local themes = require("telescope.themes")

M.git_root = ""

-- get project git root if its a git repo else use cwd
local function get_project_root()
  if M.git_root ~= "" then
    return M.git_root
  end
  local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
  if handle == nil then
    M.git_root = LazyVim.root() -- return LazyVim.root() if not a git repository
  end
  local result = handle:read("*a")
  handle:close()
  if result == "" then
    M.git_root = LazyVim.root() -- return LazyVim.root() if not a git repository
  else
    M.git_root = result:gsub("%s+$", "")
  end

  -- print("Project root: " .. M.git_root)
  return M.git_root
end

M.get_root_dir = get_project_root()

-- Custom picker for combining oldfiles and find_files to get VsCode like file search

return M
