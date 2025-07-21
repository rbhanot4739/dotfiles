return {
  "kevinhwang91/nvim-ufo",
  dependencies = {
    "kevinhwang91/promise-async",
    {
      "luukvbaal/statuscol.nvim",
      opts = function()
        local builtin = require("statuscol.builtin")
        return {
          relculright = true,
          ft_ignore = {
            "DiffviewFiles",
            "dashboard",
            "NvimTree",
            "neo-tree",
            "Outline",
            "Trouble",
          },
          segments = {
            { text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
            { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
            { text = { "%s" }, click = "v:lua.ScSa" },
          },
        }
      end,
    },
  },
  keys = {
    {
      "zR",
      function()
        require("ufo").openAllFolds()
      end,
      desc = "UFO » Open all folds",
    },
    {
      "zr",
      function()
        require("ufo").openFoldsExceptKinds()
      end,
      desc = "UFO » Open folds excepts kinds",
    },
    {
      "zM",
      function()
        require("ufo").closeAllFolds()
      end,
      desc = "UFO » Close all folds",
    },
    {
      "[z",
      function()
        require("ufo").goPreviousClosedFold()
        vim.schedule(function()
          require("ufo").peekFoldedLinesUnderCursor()
        end)
      end,
      desc = "UFO » Peek prev fold",
    },
    {
      "]z",
      function()
        require("ufo").goNextClosedFold()
        vim.schedule(function()
          require("ufo").peekFoldedLinesUnderCursor()
        end)
      end,
      desc = "UFO » Peek next fold",
    },
  },

  opts = {
    provider_selector = function(_, filetype, _)
      return ({
        typescript = { "treesitter", "indent" },
        html = { "treesitter", "indent" },
        python = { "indent" },
      })[filetype]
    end,
  },
}
