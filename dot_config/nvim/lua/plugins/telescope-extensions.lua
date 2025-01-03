return {
  -- Undo tree
  {
    "debugloop/telescope-undo.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
    },
    keys = {
      { "<leader>su", "<cmd>Telescope undo<cr>", desc = "Search undo history" },
    },
    config = function(_, opts)
      require("telescope").setup({
        extensions = {
          undo = {
            side_by_side = true,
            layout_strategy = "vertical",
            layout_config = {
              preview_height = 0.8,
            },
            mappings = {
              i = {
                ["<cr>"] = require("telescope-undo.actions").yank_additions,
                ["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
                ["<C-r>"] = require("telescope-undo.actions").restore,
              },
              n = {
                ["y"] = require("telescope-undo.actions").yank_additions,
                ["Y"] = require("telescope-undo.actions").yank_deletions,
                ["u"] = require("telescope-undo.actions").restore,
              },
            },
          },
        },
      })
      require("telescope").load_extension("undo")
    end,
  },
  -- live grep args
  {
    "nvim-telescope/telescope-live-grep-args.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local lga_actions = require("telescope-live-grep-args.actions")
      telescope.setup({
        extensions = {
          live_grep_args = {
            auto_quoting = true, -- enable/disable auto-quoting
            -- define mappings, e.g.
            mappings = { -- extend mappings
              i = {
                ["<C-k>"] = lga_actions.quote_prompt(),
                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                -- freeze the current list and start a fuzzy search in the frozen list
                ["<C-space>"] = actions.to_fuzzy_refine,
              },
            },
            -- theme = "ivy", -- use dropdown theme
          },
        },
      })

      telescope.load_extension("live_grep_args")
    end,
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
  -- smart open
  {
    "danielfalk/smart-open.nvim",
    branch = "0.2.x",
    dependencies = {
      "kkharji/sqlite.lua",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      require("telescope").load_extension("smart_open")
    end,
    keys = {
      {
        "<space><space>",
        function()
          require("telescope").extensions.smart_open.smart_open({
            cwd_only = true,
            -- show_scores = true,
            match_algorithm = "fzf",
            open_buffer_indicators = { previous = "•", others = "∘" },
          })
        end,
        desc = "Smart open files",
      },
    },
  },
}
