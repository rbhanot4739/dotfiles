return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    opts = {
      auto_install = true,
      ensure_installed = {
        "puppet",
      },
      textobjects = {
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]m"] = "@function.name",
            ["]c"] = "@class.outer",
            ["]a"] = "@parameter.inner",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[m"] = "@function.name",
            ["[c"] = "@class.outer",
            ["[a"] = "@parameter.inner",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
            ["]A"] = "@parameter.inner",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
            ["[A"] = "@parameter.inner",
          },
        },
      },
    },
    keys = {
      {
        ";",
        function()
          local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
          ts_repeat_move.repeat_last_move_next()
        end,
      },
      {
        ",",
        function()
          local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
          ts_repeat_move.repeat_last_move_previous()
        end,
      },
    },
  },
}
