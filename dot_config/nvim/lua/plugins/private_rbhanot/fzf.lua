return {
  "ibhagwan/fzf-lua",
  enabled = false,
  opts = {
    -- "telescope",
    -- use `defaults` (table or function) if you wish to set "global-picker" defaults
    defaults = {
      formatter = "path.filename_first",
      rg_glob = true,
      previewer = true,
    },
    keymap = {
      builtin = {
        ["<M-Esc>"] = "hide", -- hide fzf-lua, `:FzfLua resume` to continue
        ["<C-_>"] = "toggle-help",
        ["<M-Cr>"] = "toggle-fullscreen",
        -- Only valid with the 'builtin' previewer
        ["<F3>"] = "toggle-preview-wrap",
        ["<C-P>"] = "toggle-preview",
        -- Rotate preview clockwise/counter-clockwise
        ["<F5>"] = "toggle-preview-ccw",
        ["<F6>"] = "toggle-preview-cw",
        ["<F7>"] = "toggle-preview-ts-ctx",
        ["<F8>"] = "preview-ts-ctx-dec",
        ["<F9>"] = "preview-ts-ctx-inc",
        ["<S-Left>"] = "preview-reset",
        ["<S-down>"] = "preview-page-down",
        ["<S-up>"] = "preview-page-up",
        ["<M-S-down>"] = "preview-down",
        ["<M-S-up>"] = "preview-up",
      },
      fzf = {
        -- fzf '--bind=' options
        ["ctrl-z"] = "abort",
        ["ctrl-u"] = "unix-line-discard",
        ["ctrl-f"] = "half-page-down",
        ["ctrl-b"] = "half-page-up",
        ["ctrl-a"] = "beginning-of-line",
        ["ctrl-e"] = "end-of-line",
        ["alt-a"] = "toggle-all",
        ["alt-g"] = "first",
        ["alt-G"] = "last",
        -- Only valid with fzf previewers (bat/cat/git/etc)
        ["f3"] = "toggle-preview-wrap",
        ["ctrl-p"] = "toggle-preview",
        ["shift-down"] = "preview-page-down",
        ["shift-up"] = "preview-page-up",
      },
    },
    files = {
      cwd_header = true,
    },
  },
  keys = {
    {

      "<leader>sG",
      function()
        require("fzf-lua").live_grep_native({
          cwd = require("config.utils").get_root_dir,
          winopts = { title = "Grep(Git root)" },
        })
      end,
      desc = "Grep(Git root)",
    },
    {
      "<leader><space>",
      function()
        require("fzf-lua").oldfiles({
          cwd_only = true,
        })
      end,
      desc = "Recent files (cwd)",
    },
    {
      "<leader>sT",
      function()
        require("todo-comments.fzf").todo()
      end,
      desc = "All Todos",
    },
    {
      "<leader>st",
      function()
        require("todo-comments.fzf").todo({ keywords = { "TODO", "todo", "Todo" } })
      end,
      desc = "Todos",
    },
  },
}
