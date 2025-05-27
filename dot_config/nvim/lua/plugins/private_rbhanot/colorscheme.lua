return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = false,
      lazy = true,
      lualine_bold = true,
      on_highlights = function(hl, c)
        hl["FlashLabel"] = { fg = c.magenta2, bold = true }
      end,
      styles = {
        -- sidebars = "transparent",
        -- floats = "transparent",
      },
    },
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = true,
    opts = {
      options = {
        styles = {
          comments = "italic",
          keywords = "bold",
          types = "italic,bold",
        },
      },
    },
  },
  {
    "sainnhe/gruvbox-material",
    lazy = true,
    config = function()
      -- a comment
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_disable_italic_comment = false
      vim.g.gruvbox_material_background = "hard"
      vim.g.gruvbox_material_float_style = "dim"
      vim.g.gruvbox_material_spell_foreground = "colored"
      vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
      vim.g.gruvbox_material_current_word = "high contrast background"
    end,
  },
  -- {
  --   "f-person/auto-dark-mode.nvim",
  --   opts = {
  --     update_interval = 1000,
  --     fallback = "dark",
  --     set_dark_mode = function()
  --       vim.api.nvim_set_option_value("background", "dark", {})
  --       -- vim.cmd("colorscheme tokyonight-moon")
  --       vim.cmd("colorscheme nightfox")
  --     end,
  --     set_light_mode = function()
  --       vim.api.nvim_set_option_value("background", "light", {})
  --       -- vim.cmd("colorscheme tokyonight-day")
  --       vim.cmd("colorscheme dawnfox")
  --     end,
  --   },
  -- },
}
