-- toggle preview with <c-p> in mini.files
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    vim.keymap.set("n", "<C-p>", function()
      MiniFiles = require("mini.files")
      MiniFiles.config.windows.preview = not MiniFiles.config.windows.preview
      MiniFiles.refresh({ windows = { preview = MiniFiles.config.windows.preview } })
    end, { desc = "toggle preview" })
  end,
})

-- local set_mark = function(id, path, desc)
--   MiniFiles.set_bookmark(id, path, { desc = desc })
-- end
-- vim.api.nvim_create_autocmd("User", {
--   pattern = "MiniFilesExplorerOpen",
--   callback = function()
--     set_mark("c", vim.fn.stdpath("config"), "Config") -- path
--     set_mark("w", vim.fn.getcwd, "Working directory") -- callable
--     set_mark("~", "~", "Home directory")
--   end,
-- })
return {
  {
    "echasnovski/mini.operators",
    opts = {
      -- Exchange text regions
      exchange = {
        -- a pretty neat trick to exchange two args is `gxina` and then press `.`
        prefix = "gx",

        -- Whether to reindent new text to match previous indent
        reindent_linewise = true,
      },
      -- Replace text with register
      replace = {
        prefix = "gr",

        -- Whether to reindent new text to match previous indent
        reindent_linewise = true,
      },

      -- Sort text
      sort = {
        prefix = "gS",

        -- Function which does the sort
        func = nil,
      },
    },
    version = false,
  },
  {
    "echasnovski/mini.files",
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        content = {
          filter = function(fs_entry)
            for _, pat in ipairs({ ".*dist%-info.*", ".*egg.*", ".*typed.*", "%.so$", ".*%.pth$" }) do
              if fs_entry.name:match(pat) then
                return false
              end
            end
            return true
          end,
        },
        mappings = {
          go_in = "<s-cr>",
          go_in_plus = "l",
          go_out = "h",
          reset = ".",
          go_in_horizontal = "-",
          go_in_horizontal_plus = "_",
          go_in_vertical = "\\",
          go_in_vertical_plus = "|",
        },
        windows = {
          preview = false,
          width_nofocus = 20,
          width_focus = 40,
          width_preview = 80,
        },
        options = {
          use_as_default_explorer = true,
        },
        permanent_delete = false,
      })
    end,
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open(vim.fn.expand("%"))
          require("mini.files").reveal_cwd()
        end,
        desc = "Explorer Mini.files",
      },
      {
        "<leader>E",
        function()
          require("mini.files").open(vim.loop.cwd())
        end,
        desc = "Open mini.files (cwd)",
      },
      {
        "<leader>fm",
        function()
          require("mini.files").open(LazyVim.root(), true)
        end,
        desc = "Open mini.files (root)",
      },
    },
  },
  {
    -- left brackets [{( include the space around the brackets while the right don't
    -- [ -( hello )-] # consider this string
    -- ;d) -> [- hello -]  -- similarly ;r)< changes to [-< hello >-]
    -- ;d( -> [-hello-])  -- similarly ;r(< changes to [-<hello>-]
    "echasnovski/mini.surround",
    opts = {
      n_lines = 80,
      mappings = {
        add = "gs",
      },
    },
  },
}
