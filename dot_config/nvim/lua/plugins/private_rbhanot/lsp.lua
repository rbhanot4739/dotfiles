return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    -- event = "InsertEnter",
    opts = function(_, opts)
      -- https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "<C-k>", mode = { "i" }, false }
      keys[#keys + 1] = { "<leader>cc", mode = { "n", "v" }, false }
      keys[#keys + 1] = { "<leader>cC", mode = { "n", "v" }, false }
      keys[#keys + 1] = { "<leader>ss", mode = { "n" }, false }
      keys[#keys + 1] = { "<A-n>", mode = { "n" }, false }
      keys[#keys + 1] = { "<A-p>", mode = { "n" }, false }
      keys[#keys + 1] = { "gr", mode = { "n" }, false }
      keys[#keys + 1] = {
        "<leader>gr",
        function()
          Snacks.picker.lsp_references({ layout = "ivy" })
        end,
        nowait = true,
        desc = "References",
      }
      local util = require("lspconfig.util")
      opts["inlay_hints"] = {
        enabled = false,
      }
      opts["servers"] = {
        ruff = {
          init_options = {
            settings = {
              lint = { ignore = { "F401", "F841" } },
              format = {
                ["quote-style"] = "single",
              },
            },
          },
        },
        basedpyright = {
          root_dir = function(fname)
            local root_files = {
              "pyrightconfig.json",
              "setup.py",
              "setup.cfg",
              "pyproject.toml",
              "requirements.txt",
              "Pipfile",
              ".git",
            }
            return util.root_pattern(unpack(root_files))(fname)
          end,
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
              -- https://docs.basedpyright.com/latest/configuration/language-server-settings/
              disableOrganizeImports = true,
              -- disableTaggedHints = true,
              analysis = {
                typeCheckingMode = "standard",
                autoImportCompletions = true,
                autoSearchPaths = true,
                logLevel = "Trace",
                diagnosticSeverityOverrides = {
                  -- https://docs.basedpyright.com/latest/configuration/config-files/#type-check-diagnostics-settings
                  reportMissingTypeStubs = false,
                  -- reportUnusedVariable = "none",
                  analyzeUnannotatedFunctions = true,
                },
                exclude = {
                  "**/build",
                },
              },
            },
          },
        },
      }
    end,
  },
  {
    "williamboman/mason.nvim",
    -- opts = { ensure_installed = { "flake8", "mypy", "cspell", "markdown-oxide" } },
    opts = { ensure_installed = { "flake8", "mypy", "cspell" } },
  },
  -- linter/formatter
  -- {
  --   "mfussenegger/nvim-lint",
  --   opts = {
  --     linters_by_ft = {
  --       python = { "ruff", "mypy" },
  --     },
  --   },
  -- },
  {
    "stevearc/conform.nvim",
    opts = {
      notify_on_error = true,
      log_level = vim.log.levels.TRACE,
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
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "davidmh/cspell.nvim",
      -- "nvimtools/none-ls-extras.nvim",
    },
    event = "VeryLazy",
    opts = function(_, opts)
      local cspell = require("cspell")
      -- local null_ls = require("null-ls")

      local cspell_config = {
        config_file_preferred_name = "cspell.json",
        cspell_config_dirs = { "~/.config/", "/Users/rbhanot/development/work" },
        read_config_synchronously = true,
        on_add_to_dictionary = function(payload)
          os.execute(string.format("sort %s -o %s", payload.dictionary_path, payload.dictionary_path))
        end,
        on_add_to_json = function(payload)
          os.execute(
            string.format(
              "jq -S '.words |= sort' %s > %s.tmp && mv %s.tmp %s",
              payload.cspell_config_path,
              payload.cspell_config_path,
              payload.cspell_config_path,
              payload.cspell_config_path
            )
          )
        end,
      }
      opts.sources = vim.list_extend(opts.sources or {}, {
        -- require("none-ls.diagnostics.flake8"),
        cspell.diagnostics.with({
          config = cspell_config,
          diagnostics_postprocess = function(diagnostic)
            diagnostic.severity = vim.diagnostic.severity.HINT
          end,
        }),
        cspell.code_actions.with({ config = cspell_config }),
        -- null_ls.builtins.code_actions.refactoring,
      })
    end,
  },
}
