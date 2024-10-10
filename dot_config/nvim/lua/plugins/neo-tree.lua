return {
  "nvim-neo-tree/neo-tree.nvim",
  enabled = false,
  opts = {
    close_if_last_window = true,
    sources = { "filesystem", "git_status" },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
      },
    },
  },
}
