local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  -- if not keys.active[keys.parse({ lhs, mode = mode }).id] then
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
  -- end
end

map("n", "U", "<C-r>", { desc = "Redo" })
map("n", "$", "g$", { desc = "move with wrapped lines" })
map("n", "^", "g^", { desc = "move with wrapped lines" })

map({ "n", "o" }, "gh", "^", { remap = true, desc = "move to start of line with H" })
map({ "n", "o" }, "gl", "g_", { remap = true, desc = "move to end of line with L" })
map("n", "Y", "y$", { desc = "copy to end of line" })

map("n", "n", "nzz", { desc = "Next result" })
map("n", "N", "Nzz", { desc = "Previous result" })

-- disable arrow  keys
map({ "n", "v", "i" }, "<Up>", "<Nop>", { desc = "disable arrow keys" })
map({ "n", "v", "i" }, "<Down>", "<Nop>", { desc = "disable arrow keys" })
map({ "n", "v", "i" }, "<Left>", "<Nop>", { desc = "disable arrow keys" })
map({ "n", "v", "i" }, "<Right>", "<Nop>", { desc = "disable arrow keys" })

map("n", "<leader>gL", function()
  Snacks.lazygit({ args = { "log" }, cwd = LazyVim.root.git() })
end, { desc = "Lazygit Log" })

map("n", "<leader>L", "<cmd>LazyExtras<cr>")
-- Use backspace to go to previous buffer
map("n", "<BS>", "<C-6>", { remap = true })
-- Use enter to toggle folds
map("n", "<cr>", "za", { remap = true })

-- map jk to go to normal mode in terminal
map({ "t" }, "jk", [[<C-\><C-n>]], { desc = "open with system app" })
-- map("n", "gX", function()
--   local line = vim.api.nvim_get_current_line()
--   local url = string.match(line, "https?://[%w-_%.%?%.:/%+=&]+")
--   if url then
--     vim.ui.open(url)
--   else
--     print("No URL found on the current line")
--   end
-- end, { desc = "Open URL on the current line" })
map("n", "<leader>Y", "yig", { remap = true })
map("n", "<leader>C", "cig", { remap = true })
map("n", "<leader>D", "dig", { remap = true })
map("n", "<leader>V", "vig", { remap = true })

map("n", "q", function()
  if not vim.wo.diff then
    return "q"
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
    if bufname:find("^gitsigns://") then
      vim.schedule(function()
        vim.api.nvim_win_close(win, true)
      end)
      return ""
    end
  end

  return "q"
end, { expr = true, silent = true })
