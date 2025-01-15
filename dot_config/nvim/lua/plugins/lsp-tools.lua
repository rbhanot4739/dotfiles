return {
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "<C-k>", mode = { "i" }, false }
    end,
  },
  -- { "neovim/nvim-lspconfig",
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
    "williamboman/mason.nvim",
    opts = { ensure_installed = { "flake8", "mypy", "cspell" } },
  },
  -- linter/formatter
  {
    "mfussenegger/nvim-lint",
    linters_by_ft = {
      -- ruff isn't checking some of the stuff
      python = { "flake8", "mypy" },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      log_level = vim.log.levels.DEBUG,
      formatters_by_ft = {
        json = { "fixjson" },
        python = { "ruff_fix", "ruff_format" },
      },
      formatters = {
        injected = {
          options = {
            ignore_errors = true,
            lang_to_ft = {
              python = "python",
              json = "json",
            },
            lang_to_ext = {
              python = "py",
              json = "json",
            },
          },
        },
      },
    },
  },
  -- {
  --   "nvimtools/none-ls.nvim",
  --   dependencies = {
  --     "mason.nvim",
  --     "davidmh/cspell.nvim",
  --   },
  --   opts = function(_, opts)
  --     local cspell = require("cspell")
  --     local null_ls = require("null-ls")
  --
  --     local config = {
  --       config_file_preferred_name = "cspell.json",
  --       cspell_config_dirs = { "~/.config/" },
  --       read_config_synchronously = false,
  --     }
  --     opts.sources = vim.list_extend(opts.sources or {}, {
  --       cspell.diagnostics.with({ config = config }),
  --       cspell.code_actions.with({ config = config }),
  --       null_ls.builtins.code_actions.refactoring,
  --     })
  --   end,
  -- },
}
