local M = {}

M.git_root = ""

function M.is_git_worktree()
  local handle = io.popen("git rev-parse --is-inside-work-tree 2>/dev/null")
  local result = handle:read("*a")
  handle:close()

  if result:match("true") then
    return true
  else
    return false
  end
end

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
