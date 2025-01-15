local themes = require("telescope.themes")

return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- undo
    {
      "debugloop/telescope-undo.nvim",
      keys = {
        { "<leader>su", "<cmd>Telescope undo<cr>", desc = "Search undo history" },
      },
    },
    -- all-recent
    {
      "prochri/telescope-all-recent.nvim",
      opts = {},
      dependencies = {
        "nvim-telescope/telescope.nvim",
        "kkharji/sqlite.lua",
      },
    },
    -- Smart open
    {
      "danielfalk/smart-open.nvim",
      -- branch = "0.2.x",
      keys = {
        {
          "<space><space>",
          function()
            -- require("telescope").extensions.smart_open.smart_open(require("telescope.themes").get_dropdown({
            require("telescope").extensions.smart_open.smart_open({
              -- winblend = 1,
              match_algorithm = "fzf",
              open_buffer_indicators = { previous = "•", others = "∘" },
              cwd_only = true,
              layout_config = {
                height = 0.6,
                -- width = 0.7,
                preview_width = 0.7,
                -- preview_cutoff = 92,
              },
              previewer = false,
            })
          end,
          desc = "Smart open files",
        },
      },
      dependencies = {
        "kkharji/sqlite.lua",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      },
    },

    -- live-grep-args
    {
      "nvim-telescope/telescope-live-grep-args.nvim",
      keys = {
        {
          "<leader>sg",
          function()
            require("telescope").extensions.live_grep_args.live_grep_args({
              prompt_title = "Live Grep (Args)",
            })
          end,
          -- mode = { "n", "v" },
          desc = "Live grep (Args)",
        },
        {
          "<leader>sG",
          function()
            require("telescope").extensions.live_grep_args.live_grep_args({
              cwd = require("utils").get_root_dir,
              additional_args = { "--follow" },
              prompt_title = "Live Grep (Args Git root)",
            })
          end,
          -- mode = { "n", "v" },
          desc = "Live grep (Args [Git root])",
        },
        {
          "<leader>sP",
          function()
            require("telescope").extensions.live_grep_args.live_grep_args({
              cwd = vim.fn.stdpath("data"),
              additional_args = { "--follow" },
              prompt_title = "Live grep Plugin files",
            })
          end,
          -- mode = { "n", "v" },
          desc = "Live grep Plugin files",
        },
        {
          "<leader>sw",
          function()
            require("telescope-live-grep-args.shortcuts").grep_word_under_cursor({
              additional_args = { "--follow" },
              prompt_title = "Grep word under cursor",
            })
          end,
          desc = "Grep word under cursor",
        },
        {
          "<leader>sW",
          function()
            require("telescope-live-grep-args.shortcuts").grep_word_under_cursor({
              additional_args = { "--follow" },
              cwd = require("utils").get_root_dir,
              prompt_title = "Grep word under cursor(Git root)",
            })
          end,
          desc = "Grep word under cursor(Git root)",
        },
      },
    },
    -- toggleterm
    {
      "ryanmsnyder/toggleterm-manager.nvim",
      dependencies = {
        "akinsho/toggleterm.nvim",
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim", -- only needed because it's a dependency of telescope
      },
      config = function()
        local toggleterm_manager = require("toggleterm-manager")
        toggleterm_manager.setup({
          mappings = { -- key mappings bound inside the telescope window
            i = {
              ["<CR>"] = { action = require("toggleterm-manager").actions.toggle_term, exit_on_action = true }, -- toggles terminal open/closed
              ["<C-n>"] = { action = require("toggleterm-manager").actions.create_term, exit_on_action = false }, -- creates a new terminal buffer
              ["<C-d>"] = { action = require("toggleterm-manager").actions.delete_term, exit_on_action = false }, -- deletes a terminal buffer
              ["<C-r>"] = { action = require("toggleterm-manager").actions.rename_term, exit_on_action = false }, -- provides a prompt to rename a terminal
              ["<Tab>"] = { action = require("telescope.actions").move_selection_next },
              ["<S-Tab>"] = { action = require("telescope.actions").move_selection_previous },
            },
            n = {
              ["<CR>"] = { action = require("toggleterm-manager").actions.toggle_term, exit_on_action = true }, -- toggles terminal open/closed
              ["<C-n>"] = { action = require("toggleterm-manager").actions.create_term, exit_on_action = false }, -- creates a new terminal buffer
              ["D"] = { action = require("toggleterm-manager").actions.delete_term, exit_on_action = false }, -- deletes a terminal buffer
              ["C"] = { action = require("toggleterm-manager").actions.rename_term, exit_on_action = false }, -- provides a prompt to rename a terminal
              ["<Tab>"] = { action = require("telescope.actions").move_selection_next },
              ["<S-Tab>"] = { action = require("telescope.actions").move_selection_previous },
            },
          },
        })
      end,
      keys = {
        { "<leader>ft", "<cmd>Telescope toggleterm_manager theme=ivy<cr>", desc = "Find terminals" },
      },
    },
  },
  opts = function(_, opts)
    local actions = require("telescope.actions")
    local action_layout = require("telescope.actions.layout")
    opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
      -- path_display = {
      --   -- "smart",
      --   -- shorten = { len = 3, exclude = { -3, -2, -1 } },
      --   "filename_first",
      -- },
      path_display = function(opts, path)
        local tail = require("telescope.utils").path_tail(path)

        local Path = require("plenary.path")
        local relative_path = vim.fn.fnamemodify(Path:new(path):make_relative(vim.loop.cwd()), ":h")
        path = string.format("%s  %s", tail, relative_path)

        local highlights = {
          {
            {
              #tail + 2, -- highlight start position
              #path, -- highlight end position
            },
            "Directory", -- highlight group name
          },
        }

        return path, highlights
      end,
      prompt_prefix = "🔍 ",
      file_ignore_patterns = { "static/", "docs/", "pages/" },
      preview = {
        filesize_limit = 0.1, -- MB
      },
      dynamic_preview_title = true,
      mappings = {
        n = {
          ["D"] = actions.delete_buffer + actions.move_to_top,
          ["K"] = actions.cycle_history_prev,
          ["J"] = actions.cycle_history_next,
          ["<C-p>"] = action_layout.toggle_preview,
        },
        i = {
          -- ["<esc>"] = actions.close,
          ["<C-Down>"] = actions.cycle_history_next,
          ["<C-Up>"] = actions.cycle_history_prev,
          ["<c-d>"] = actions.delete_buffer + actions.move_to_top,
          ["<C-p>"] = action_layout.toggle_preview,
        },
      },
    })
    opts.pickers = {
      buffers = {
        previewer = false,
        layout_config = {
          height = 0.6,
          -- width = 0.7,
          preview_width = 0.7,
          -- preview_cutoff = 92,
        },
      },
      previewer = false,
      layout_config = {
        height = 0.6,
        -- width = 0.7,
        preview_width = 0.7,
        -- preview_cutoff = 92,
      },
      find_files = {
        -- theme = "dropdown",
        previewer = false,
        layout_config = {
          height = 0.6,
          -- width = 0.7,
          preview_width = 0.7,
          -- preview_cutoff = 92,
        },
      },
      help_tags = {
        theme = "ivy",
        layout_config = {
          preview_width = 0.7,
          -- height = 0.5,
        },
      },
    }
    opts.extensions = {
      undo = {
        side_by_side = false,
        layout_strategy = "vertical",
        -- layout_config = {
        --   preview_height = 0.8,
        -- },
        mappings = {
          i = {
            ["<cr>"] = require("telescope-undo.actions").yank_additions,
            ["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
            ["<C-CR>"] = require("telescope-undo.actions").restore,
            ["<C-y>"] = require("telescope-undo.actions").yank_additions,
            ["<C-x>"] = require("telescope-undo.actions").yank_deletions,
            ["<C-r>"] = require("telescope-undo.actions").restore,
          },
          n = {
            ["y"] = require("telescope-undo.actions").yank_additions,
            ["Y"] = require("telescope-undo.actions").yank_deletions,
            ["u"] = require("telescope-undo.actions").restore,
          },
        },
      },

      smart_open = {},
      live_grep_args = {
        auto_quoting = true, -- enable/disable auto-quoting
        -- define mappings, e.g.
        mappings = { -- extend mappings
          i = {
            ["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt(),
            ["<C-i>"] = require("telescope-live-grep-args.actions").quote_prompt({ postfix = " --iglob " }),
            -- freeze the current list and start a fuzzy search in the frozen list
            ["<C-space>"] = require("telescope.actions").to_fuzzy_refine,
          },
        },
        theme = "dropdown", -- use dropdown theme
        layout_config = { mirror = false, width = 0.8 }, -- mirror preview pane
      },
    }
    return opts
  end,
  keys = {
    { "<leader><space>", false },
    { "<leader>sw", false },
    { "<leader>sW", false },
    { "<leader>:", false },
    {
      "<leader>ss",
      function()
        local symbols = LazyVim.config.get_kind_filter()
        table.insert(symbols, "Constant")
        require("telescope.builtin").lsp_document_symbols({
          symbols = symbols,
        })
      end,
      desc = "Goto Symbol",
    },
    {
      "<leader>sS",
      function()
        local symbols = LazyVim.config.get_kind_filter()
        table.insert(symbols, "Constant")
        require("telescope.builtin").lsp_dynamic_workspace_symbols({
          symbols = symbols,
        })
      end,
      desc = "Goto Symbol (Workspace)",
    },
    {
      "<leader>fr",
      function()
        require("telescope.builtin").oldfiles({
          cwd = require("utils").get_root_dir,
          prompt_title = "Recent Files (Git Root)",
        })
      end,
      desc = "Find recent files (Git Root)",
    },

    -- git
    {
      "<leader>gB",
      function()
        require("telescope.builtin").git_branches({
          show_remote_tracking_branches = false,
          prompt_title = "Git branches (local)",
        })
      end,
      desc = "Git Branches (Local)",
    },
    { "<leader>gc", false },
    { "<leader>gC", "<cmd>Telescope git_commits<cr>", desc = "All commits" },

    { "<leader>sc", "<cmd>Telescope commands<cr>", desc = "Commands" },
    -- telescope picker for files in current file's parent directory
    {
      "<leader>fa",
      [[<cmd>lua require("telescope.builtin").find_files({cwd=vim.fn.expand("%:p:h")})<cr>]],
      desc = "Find adjacent files",
    },
    {
      "<C-r>",
      function()
        require("telescope").extensions.yank_history.yank_history({})
      end,
      mode = { "i" },
      { desc = "Paste yank ring" },
    },
    { "zf", "<cmd>Telescope spell_suggest theme=cursor<cr>", desc = "Spell suggest" },
    { "<leader>/", "<cmd>Telescope search_history theme=dropdown<cr>", desc = "Search history" },
    { "<leader>?", "<cmd>Telescope command_history theme=dropdown<cr>", desc = "Command history" },
    -- { "<leader>,", "<cmd>Telescope vim_options<cr>", desc = "Search Vim options" },
    { "<leader>st", "<cmd>TodoTelescope keywords=TODO,Todo,todo<cr>", desc = "Todos" },
    { "<leader>sT", "<cmd>TodoTelescope<cr>", desc = "All Todos" },
    {
      "<leader>fP",
      function()
        require("telescope.builtin").find_files({
          prompt_title = " Find Plugin files",
          cwd = vim.fn.stdpath("data"),
          find_command = { "fd", "--type", "f", ".lua$" },
        })
      end,
      desc = "Find Plugin files",
    },
  },
}
