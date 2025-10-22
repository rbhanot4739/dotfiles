return {
  {
    "neovim/nvim-lspconfig",
    -- dependencies = { "saghen/blink.cmp" },
    opts = function(_, opts)
      -- https://www.lazyvim.org/plugins/lsp
      opts.servers["*"].keys = opts.servers["*"].keys or {}
      vim.list_extend(opts.servers["*"].keys, {
        { "<leader>cc", false },
        { "<leader>cC", false },
        { "<leader>ss", false },
        { "<A-n>", false },
        { "<A-p>", false },
        { "gr", false },
        {
          "<leader>gr",
          function()
            Snacks.picker.lsp_references({ layout = "ivy" })
          end,
          nowait = true,
          desc = "References",
        },
        {
          "<leader>gi",
          function()
            Snacks.picker.lsp_incoming_calls()
          end,
        },
        {
          "<leader>go",
          function()
            Snacks.picker.lsp_outgoing_calls()
          end,
        },
      })
      local util = require("lspconfig.util")
      opts.servers.ruff.init_options.settings =
        vim.tbl_deep_extend("force", opts.servers.ruff.init_options.settings or {}, {
          lint = { ignore = { "F401", "F841" } },
          format = { ["quote-style"] = "single" },
        })
      -- opts.servers.basedpyright.root_dir = function(fname)
      --   local root_files = {
      --     "pyrightconfig.json",
      --     "setup.py",
      --     "setup.cfg",
      --     "pyproject.toml",
      --     "requirements.txt",
      --     "Pipfile",
      --     ".git",
      --   }
      --   return util.root_pattern(unpack(root_files))(fname)
      -- end
      opts.servers.basedpyright.capabilities =
        vim.tbl_deep_extend("force", opts.servers.basedpyright.capabilities or {}, {
          textDocument = {
            publishDiagnostics = {
              tagSupport = {
                valueSet = { 2 },
              },
            },
          },
        })
      opts.servers.basedpyright.settings = vim.tbl_deep_extend("force", opts.servers.basedpyright.settings or {}, {
        basedpyright = {
          -- https://docs.basedpyright.com/latest/configuration/language-server-settings/
          disableOrganizeImports = true,
          disableTaggedHints = false,
          analysis = {
            typeCheckingMode = "standard",
            autoImportCompletions = true,
            autoSearchPaths = true,
            logLevel = "Trace",
            useTypingExtensions = true,
            autoFormatStrings = true,
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
      })
      opts["inlay_hints"] = { enabled = false }
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "flake8", "mypy", "cspell", "copilot-language-server", "protols" } },
  },
  {
    "stevearc/conform.nvim",
    keys = {
      {
        "<leader>cf",
        mode = { "n", "v" },
        function()
          require("conform").format({ async = true }, function(err)
            if not err then
              local mode = vim.api.nvim_get_mode().mode
              if vim.startswith(string.lower(mode), "v") then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
              end
            end
          end)
        end,
        desc = "Toggle Conform",
      },
    },
    opts = {
      notify_on_error = true,
      log_level = vim.log.levels.TRACE,
      formatters_by_ft = {
        json = { "fixjson" },
        python = { "ruff_fix", "ruff_format" },
        go = { "gofumpt", "goimports" },
        sh = { "shfmt" },
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
