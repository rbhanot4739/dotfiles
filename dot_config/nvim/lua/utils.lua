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

function M.get_visual_selection()
  local start_line, end_line
  if vim.fn.mode() == "v" or vim.fn.mode() == "V" then
    start_line = vim.fn.line("v")
    end_line = vim.fn.line(".")
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
  end
  return start_line, end_line
end

function M.trim_path(path)
  -- convert the path to a short form
  -- vim.fn.expand("%:~:.:h")
  -- 1. ":~" – Replaces the home directory path with "~".
  -- 2. ":." – Makes the path relative to the current working directory (or substitutes it with "." if applicable).
  -- 3. ":h" – Returns the directory part (i.e. the head) of that expanded path.

  path = path ~= nil and type(path) == "string" and vim.fn.fnamemodify(path, ":~") or vim.fn.expand("%:~:.:h")
  -- trim some virtual environment paths
  if path:find("environment") then
    local parts = vim.split(path, "/")
    if #parts >= 2 then
      path = table.concat({ "...", parts[#parts - 1], parts[#parts] }, "/")
    end
  end
  if string.len(path) > 35 then
    local parts = vim.split(path, "/")
    for i = 1, #parts - 1 do
      if string.len(parts[i]) > 2 then
        parts[i] = string.sub(parts[i], 1, 2)
      end
    end
    path = table.concat(parts, "/")
  end
  return path
end

-- https://github.com/folke/snacks.nvim/blob/bc0630e43be5699bb94dadc302c0d21615421d93/lua/snacks/picker/util/init.lua#L207
function M.title(str)
  return table.concat(
    vim.tbl_map(function(s)
      return s:sub(1, 1):upper() .. s:sub(2)
    end, vim.split(str, "_")),
    " "
  )
end

return M
