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
    "sainnhe/everforest",
    config = function()
      vim.g.everforest_better_performance = 1
      vim.g.everforest_background = "hard"
      vim.g.everforest_float_style = "dim"
      vim.g.everforest_enable_italic = 1
      vim.g.everforest_enable_bold = 1
      vim.g.everforest_disable_italic_comment = false
      vim.g.everforest_spell_foreground = "colored"
      vim.g.everforest_diagnostic_virtual_text = "colored"
      vim.g.everforest_current_word = "high contrast background"
    end,
  },
  {
    "sainnhe/gruvbox-material",
    lazy = true,
    config = function()
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
}
