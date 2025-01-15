-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local Util = require("lazyvim.util")
if not vim.g.vscode then
  local function map(mode, lhs, rhs, opts)
    local keys = require("lazy.core.handler").handlers.keys
    ---@cast keys LazyKeysHandler
    -- do not create the keymap if a lazy keys handler exists
    if not keys.active[keys.parse({ lhs, mode = mode }).id] then
      opts = opts or {}
      opts.silent = opts.silent ~= false
      vim.keymap.set(mode, lhs, rhs, opts)
    end
  end

  map("n", "[<Space>", "O<Esc>j", { desc = "add blank line above keeping cursor on original place" })
  map("n", "]<Space>", "o<Esc>k", { desc = "add blank line below keeping cursor on original line" })

  map("n", "$", "g$", { desc = "move with wrapped lines" })
  map("n", "^", "g^", { desc = "move with wrapped lines" })

  map("n", "gh", "^", { desc = "move to start of line with H" })
  map("n", "gl", "g_", { desc = "move to end of line with L" })
  map("n", "G", "Gzz", { desc = "move to end of file and center the contents" })
  map("n", "Y", "y$", { desc = "copy to end of line" })

  -- disable arrow  keys
  map({ "n", "v", "i" }, "<Up>", "<Nop>", { desc = "disable arrow keys" })
  map({ "n", "v", "i" }, "<Down>", "<Nop>", { desc = "disable arrow keys" })
  map({ "n", "v", "i" }, "<Left>", "<Nop>", { desc = "disable arrow keys" })
  map({ "n", "v", "i" }, "<Right>", "<Nop>", { desc = "disable arrow keys" })
  -- delete lazyVim builtin keymaps
  vim.keymap.del({ "n", "t" }, "<c-_>")
  -- vim.keymap.del("n", "<leader>ft")

  -- add a mapping to replace visual selection in file
  -- vim.keymap.set("v", "<leader>*", 'y:%s/\\V<c-r>"//g<left><left>', { desc = "replace visual selection" })
  -- replace word under cursor
  -- map({ "n" }, "<leader>*", ":%s/\\<<C-r><C-w>\\>//g<left><left>", { desc = "replace word under cursor" })

  -- lazygit
  map("n", "<leader>gG", function()
    Snacks.lazygit({ cwd = LazyVim.root.git() })
  end, { desc = "Lazygit (Root Dir)" })

  map("n", "<leader>gL", function()
    Snacks.lazygit({ args = { "log" }, cwd = LazyVim.root.git() })
  end, { desc = "Lazygit Log" })
  map("n", "<leader>lx", "<cmd>LazyExtras<cr>")
  map("n", "<BS>", "<C-6>", { remap = true })
end
