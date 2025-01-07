return {
  "ibhagwan/fzf-lua",
  enabled = false,
  opts = {
    "telescope",
    defaults = {
      formatter = "path.filename_first",
      rg_glob = true,
    },
    files = {
      cwd_header = true,
    },
  },
  -- keys = {
  --   {
  --
  --     "<leader>sG",
  --     function()
  --       require("fzf-lua").live_grep_native({
  --         cwd = require("utils").get_root_dir,
  --         winopts = { title = "Grep(Git root)" },
  --       })
  --     end,
  --     desc = "Grep(Git root)",
  --   },
  --   {
  --     "<leader><space>",
  --     function()
  --       require("fzf-lua").oldfiles({
  --         cwd_only = true,
  --       })
  --     end,
  --     desc = "Recent files (cwd)",
  --   },
  --   {
  --     "<leader>sT",
  --     function()
  --       require("todo-comments.fzf").todo()
  --     end,
  --     desc = "All Todos",
  --   },
  --   {
  --     "<leader>st",
  --     function()
  --       require("todo-comments.fzf").todo({ keywords = { "TODO", "todo", "Todo" } })
  --     end,
  --     desc = "Todos",
  --   },
  -- },
}
