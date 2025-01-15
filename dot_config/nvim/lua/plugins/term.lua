function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set("t", "<esc><esc>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
  vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

local ft_repls = {}
function ft_repl_toggle(ft)
  local Terminal = require("toggleterm.terminal").Terminal
  if ft == "toggleterm" then
    require("toggleterm").toggle_all(true)
  elseif ft_repls[ft] ~= nil then
    return ft_repls[ft]:toggle()
  else
    local ft_cmds = { python = "ipython", lua = "lua" }
    local ft_repl = Terminal:new({
      display_name = (ft_cmds[ft] .. "-" or "") .. "repl",
      cmd = ft_cmds[ft] or nil,
      hidden = false,
      direction = "float",
    })
    ft_repls[ft] = ft_repl
    ft_repl:toggle()
  end
end

vim.keymap.set({ "n", "t" }, "<M-/>", function()
  local ft = vim.bo.filetype
  ft_repl_toggle(ft)
end, { desc = "Open repl in floating window", noremap = true, silent = true })

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    winbar = {
      enabled = true,
      name_formatter = function(term) --  term: Terminal
        return term.name
      end,
    },
    -- open_mapping = "<c-//>", -- use <c-/>
    open_mapping = "", -- use <c-/>
    insert_mappings = true,
    terminal_mappings = true,
  },
  keys = {},
}
