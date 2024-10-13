return {
  -- {
  --   "neovim/nvim-lspconfig",
  --   event = "LazyFile",
  --   opts = function(_, opts)
  --     -- https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps
  --     local util = require("lspconfig.util")
  --     local root_files = {
  --       ".git",
  --       "setup.py",
  --       "setup.cfg",
  --       "pyrightconfig.json",
  --       "pyproject.toml",
  --       "requirements.txt",
  --       "Pipfile",
  --     }
  --     local keys = require("lazyvim.plugins.lsp.keymaps").get()
  --     keys[#keys + 1] = { "<M-n>", false }
  --     keys[#keys + 1] = { "<M-p>", false }
  --     vim.tbl_extend("force", opts, {
  --       codelens = {
  --         enabled = true,
  --       },
  --       servers = {
  --         basedpyright = {
  --           root_dir = function(fname)
  --             return util.root_pattern(unpack(root_files))(fname)
  --           end,
  --           capabilities = {
  --             textDocument = {
  --               publishDiagnostics = {
  --                 tagSupport = {
  --                   valueSet = { 2 },
  --                 },
  --               },
  --             },
  --           },
  --           settings = {
  --             basedpyright = {
  --               analysis = {
  --                 diagnosticMode = "workspace",
  --                 typeCheckingMode = "standard",
  --                 -- ignore = { "*" },
  --                 diagnosticSeverityOverrides = {
  --                   reportUndefinedVariable = false,
  --                   reportUnusedVariable = "warning", -- or anything
  --                   -- reportUnknownParameterType = false,
  --                   -- reportUnknownArgumentType = false,
  --                   -- reportUnknownLambdaType = false,
  --                   -- reportUnknownVariableType = false,
  --                   -- reportUnknownMemberType = false,
  --                   -- reportMissingParameterType = false,
  --                 },
  --               },
  --             },
  --           },
  --         },
  --       },
  --     })
  --   end,
  -- },
  {
    "mfussenegger/nvim-lint",
    linters_by_ft = {
      -- ruff isn't checking some of the stuff
      python = { "flake8", "mypy" },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "flake8", "mypy" } },
  },
}
