-- local util = require("lspconfig.util")
local root_files = {
  "setup.py",
  "setup.cfg",
  "pyrightconfig.json",
  "pyproject.toml",
  "requirements.txt",
  "Pipfile",
  ".git",
}
return {
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    opts = {
      codelens = {
        enabled = true,
      },
      servers = {
        bashls = {},
        jsonls = {},
        yamlls = {},
        vimls = {},
        taplo = {},
        basedpyright = {
          -- root_dir = function(fname)
          --   return util.root_pattern(unpack(root_files))(fname)
          -- end,
          capabilities = {
            textDocument = {
              publishDiagnostics = {
                tagSupport = {
                  valueSet = { 2 },
                },
              },
            },
          },
          settings = {
            basedpyright = {
              analysis = {
                -- diagnosticMode = "workspace",
                typeCheckingMode = "standard",
                -- ignore = { "*" },
                diagnosticSeverityOverrides = {
                  reportUndefinedVariable = false,
                  reportUnusedVariable = "warning", -- or anything
                  -- reportUnknownParameterType = false,
                  -- reportUnknownArgumentType = false,
                  -- reportUnknownLambdaType = false,
                  -- reportUnknownVariableType = false,
                  -- reportUnknownMemberType = false,
                  -- reportMissingParameterType = false,
                },
              },
            },
          },
        },
      },
    },
  },
}
