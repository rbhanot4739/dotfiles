local M = {}
-- M.is_grep = nil
--
-- local function switch_grep_files(picker, _)
--   -- switch b/w grep and files picker
--   local snacks = require("snacks")
--   local cwd = picker.input.filter.cwd
--
--   picker:close()
--
--   if M.is_grep then
--     -- if we are inside grep picker then switch to files picker and set M.is_grep = false
--     local pattern = picker.input.filter.search or picker.input.filter.pattern
--     snacks.picker.files({ cwd = cwd, pattern = pattern })
--     M.is_grep = false
--     return
--   else
--     -- if we are inside files picker then switch to grep picker and set M.is_grep = true
--     local pattern = picker.input.filter.pattern or picker.input.filter.search
--     snacks.picker.grep({ cwd = cwd, search = pattern })
--     M.is_grep = true
--   end
-- end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = {
    {
      "?",
      function()
        Snacks.picker.lines()
        -- Snacks.picker.search_history({ layout = { preset = "dropdown", preview = false } })
      end,
      desc = "Fuzzy find files",
    },
    {
      "<leader>/",
      function()
        Snacks.picker.search_history({ layout = { preset = "dropdown", preview = false } })
      end,
      desc = "Fuzzy find files",
    },
    {
      "<leader>?",
      function()
        Snacks.picker.command_history({ layout = { preset = "dropdown", preview = false } })
      end,
    },
    {
      "<c-r>",
      mode = { "i" },
      [[<cmd>YankyRingHistory<cr>]],
      desc = "Paste yank ring",
    },
    {
      "zf",
      function()
        Snacks.picker.spelling({
          layout = {
            preset = "select",
            layout = {
              relative = "cursor",
              width = 30,
              min_width = 0,
              row = 1,
            },
          },
        })
      end,
      desc = "Spell suggest",
    },
    {
      "<leader>fa",
      function()
        Snacks.picker.files({ cwd = vim.fn.expand("%:p:h") })
      end,
      -- [[<cmd>lua require("telescope.builtin").find_files({cwd=vim.fn.expand("%:p:h")})<cr>]],
      desc = "Find adjacent files",
    },
    {
      "<leader>su",
      function()
        Snacks.picker.undo()
      end,
      desc = "Search Undo tree",
    },
    {
      "<leader>oo",
      function()
        local vault = vim.fn.expand("~/obsidian-vault/")
        Snacks.picker.pick("grep", {
          cwd = vault,
          actions = {
            create_note = function(picker, item)
              picker:close()
              vim.cmd("ObsidianNew " .. picker.finder.filter.search)
            end,
          },
          win = {
            input = {
              keys = {
                ["<c-x>"] = { "create_note", desc = "Create new note", mode = { "i", "n" } },
              },
            },
          },
        })
      end,
    },
    {
      "<leader>fP",
      function()
        require("snacks").picker.pick("files", {
          cwd = vim.fn.stdpath("data")[1] or vim.fn.stdpath("data"),
          cmd = "fd",
          args = { "--type", "f", ".lua$" },
        })
      end,
      desc = "Find Plugin files",
    },
    {
      "<leader>fg",
      function()
        require("snacks").picker.pick("files", {
          cwd = require("utils").get_root_dir,
        })
      end,
      desc = "Find git files",
    },
    -- grep mappings
    { "<leader>sw", LazyVim.pick("grep_word"), desc = "Visual selection or word (Root Dir)", mode = { "n", "x" } },
    {
      "<leader>sW",
      LazyVim.pick("grep_word", { cwd = require("utils").get_root_dir }),
      desc = "Visual selection or word (git)",
      mode = { "n", "x" },
    },
    {
      "<leader>sG",
      function()
        Snacks.picker.pick("grep", {
          cwd = require("utils").get_root_dir,
          prompt_title = "Grep (Args Git root)",
        })
      end,
      -- mode = { "n", "v" },
      desc = "Live grep (Args [Git root])",
    },
    {
      "<leader>ss",
      function()
        table.insert(LazyVim.config.kind_filter.default, "Constant")
        Snacks.picker.lsp_symbols({
          filter = LazyVim.config.kind_filter,
        })
      end,
      desc = "LSP Symbols",
    },
    {
      "<leader>sS",
      function()
        table.insert(LazyVim.config.kind_filter.default, "Constant")
        Snacks.picker.lsp_workspace_symbols({ filter = LazyVim.config.kind_filter })
      end,
      desc = "LSP Workspace Symbols",
    },
    {
      "<leader><space>",
      function()
        Snacks.picker.smart({ filter = { cwd = true } })
      end,
      desc = "Smart Picker",
    },
    -- git
    {
      "<leader>gB",
      function()
        Snacks.picker.git_branches({ layout = "ivy" })
      end,
      desc = "Git branches",
    },
    {
      "<leader>gy",
      mode = { "n", "x" },
      function()
        Snacks.gitbrowse.open()
      end,
      desc = "Git Browse",
    },
  },
  opts = {
    picker = {
      layouts = {
        --   select = {
        --     layout = {
        --       relative = "cursor",
        --       -- width = 70,
        --       -- min_width = 0,
        --       -- row = 1,
        --     },
        --   },
      },
      sources = {
        smart = {
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "v" } },
              },
            },
          },
        },
        recent = {
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "v" } },
              },
            },
          },
        },
        buffers = {
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "v" } },
              },
            },
          },
        },
        files = {
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "v" } },
              },
            },
          },
        },
        grep = {
          win = {
            input = {
              keys = {
                ["<c-k>"] = { "switch_grep_files", desc = "Switch to grep", mode = { "i", "v" } },
              },
            },
          },
        },
      },
      formatters = {
        file = {
          filename_first = true, -- display filename before the file path
        },
      },
      icons = {
        kinds = require("config.utils").icons.kinds,
      },
      win = {
        -- input window
        input = {
          keys = {
            ["<TAB>"] = { "list_down", mode = { "i", "n" } },
            ["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
            ["<C-Space>"] = { "select_and_next", mode = { "i", "n" } },
            ["<A-Space>"] = { "select_and_prev", mode = { "i", "n" } },
          },
        },
      },
    },
    indent = { enabled = true },
    scroll = { enabled = true },
    gitbrowse = {
      enabled = true,
      config = function(opts, defaults)
        table.insert(opts.remote_patterns, { "^(https://).+@(.*):(.*)", "%1%2/%3" })
      end,
    },
    dashboard = {
      enabled = false,
      preset = {
        keys = {
          {
            icon = " ",
            key = "f",
            desc = "Find File",
            action = function()
              local has_telescope, telescope = pcall(require, "telescope")
              local has_fzf, fzf = pcall(require, "fzf-lua")
              local has_snacks, snacks = pcall(require, "snacks")
              if has_telescope then
                telescope.extensions.smart_open.smart_open({ cwd_only = true })
              elseif has_fzf then
                fzf.files({ hidden = true })
              else
                snacks.picker.pick("files")
              end
            end,
          },
          {
            icon = " ",
            key = "g",
            desc = "Grep",
            action = function()
              local has_telescope, telescope = pcall(require, "telescope")
              local has_fzf, fzf = pcall(require, "fzf-lua")
              local has_snacks, snacks = pcall(require, "snacks")
              if has_telescope then
                telescope.extensions.live_grep_args.live_grep_args({
                  prompt_title = "Live Grep",
                })
              elseif has_fzf then
                fzf.grep({ hidden = true })
              else
                snacks.picker.pick("grep")
              end
            end,
          },
          -- { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          -- { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", action = ":SessionRestore" },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "l", desc = "Sessions", action = ":SessionSearch" },
          { icon = "󰒲 ", key = "x", desc = "LazyExtras", action = ":LazyExtras" },
          { icon = "? ", key = "h", desc = "Help", action = ":Telescope help_tags" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
    scratch = {
      win_by_ft = {
        lua = {
          keys = {
            ["source"] = {
              "<cr>",
              function(self)
                local name = "scratch." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ":e")
                Snacks.debug.run({ buf = self.buf, name = name })
              end,
              desc = "Source buffer",
              mode = { "n", "x" },
            },
          },
        },
        python = {
          keys = {
            ["source"] = {
              "<cr>",
              function(self)
                local name = "scratch." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ":e")
                Snacks.debug.run({ buf = self.buf, name = name })
              end,
              desc = "Source buffer",
              mode = { "n", "x" },
            },
          },
        },
      },
    },
  },
}
