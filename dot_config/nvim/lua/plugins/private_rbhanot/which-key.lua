-- https://github.com/LazyVim/LazyVim/blob/d1529f650fdd89cb620258bdeca5ed7b558420c7/lua/lazyvim/plugins/editor.lua#L175
return {
  "folke/which-key.nvim",
  opts = {
    spec = {
      {
        mode = { "n", "v" },
        { "<leader>s", group = "" },
      },
    },
  },
  keys = {
    { "<leader>?", false },
  },
}
