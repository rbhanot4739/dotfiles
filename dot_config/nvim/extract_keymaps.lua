-- Script to extract all keymaps from the current Neovim config
local function get_all_keymaps()
  local modes = { 'n', 'i', 'v', 'x', 't', 'c', 'o', 's' }
  local all_keymaps = {}
  
  for _, mode in ipairs(modes) do
    local keymaps = vim.api.nvim_get_keymap(mode)
    for _, keymap in ipairs(keymaps) do
      table.insert(all_keymaps, {
        mode = mode,
        lhs = keymap.lhs,
        rhs = keymap.rhs or keymap.callback,
        desc = keymap.desc,
        buffer = keymap.buffer
      })
    end
  end
  
  return all_keymaps
end

local keymaps = get_all_keymaps()
for _, keymap in ipairs(keymaps) do
  if keymap.desc and keymap.desc ~= "" then
    print(string.format("%s | %s | %s | %s", 
      keymap.mode, 
      keymap.lhs, 
      type(keymap.rhs) == "string" and keymap.rhs or "function", 
      keymap.desc))
  end
end