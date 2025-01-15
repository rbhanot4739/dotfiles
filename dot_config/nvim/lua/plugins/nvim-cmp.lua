local config_utils = require("config.utils")
return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "rcarriga/cmp-dap",
      "hrsh7th/cmp-cmdline",
      "lukas-reineke/cmp-rg",
      -- { "uga-rosa/cmp-dictionary", opts = { paths = { "/usr/share/dict/words" }, exact_length = 2 } },
      {
        "uga-rosa/cmp-dictionary",
        opts = {
          paths = { vim.fn.expand("~") .. "/words.txt" },
          exact_length = 2,
          first_case_insensitive = true,
          document = {
            enable = true,
            command = { "wn", "${label}", "-over" },
          },
        },
      },
    },
    opts = function(_, opts)
      -- local has_words_before = function()
      --   unpack = unpack or table.unpack
      --   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      --   return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      -- end
      local has_words_before = function()
        if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
          return false
        end
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
      end
      local cmp = require("cmp")
      local neogen = require("neogen")
      local cmd_mapping = cmp.mapping.preset.cmdline()
      -- make <s-cr> select the entry, prevents redundant <Tab> & <S-Tab> presses
      cmd_mapping["<cr>"] = {
        c = cmp.mapping.confirm({ select = true }),
      }
      cmd_mapping["<C-a>"] = { c = cmp.mapping.abort() }
      local luasnip = require("luasnip")
      table.insert(opts.sources, { name = "render-markdown" })
      table.insert(opts.sources, { name = "rg" })
      table.insert(opts.sources, {
        name = "dictionary",
        keyword_length = 2,
      })
      -- insert copilot completions after lsp
      -- table.remove(opts.sources, 1)
      -- table.insert(opts.sources, { name = "copilot",
      --   group_index = 2,
      --   priority = 100,
      -- })

      -- --------------------------------------cmdline setup start--------------------------------------
      -- `/` cmdline setup.
      cmp.setup.cmdline("/", {
        -- mapping = cmp.mapping.preset.cmdline(),
        mapping = cmd_mapping,
        sources = {
          { name = "buffer" },
        },
      })
      -- `:` cmdline setup.
      cmp.setup.cmdline(":", {
        mapping = cmd_mapping,
        -- mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          {
            name = "cmdline",
            option = {
              ignore_cmds = { "Man", "!" },
            },
          },
        }),
      })
      -- cmdline setup done

      -- dap repl completion
      opts.enabled = function()
        return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt" or require("cmp_dap").is_dap_buffer()
      end
      local dap_types = { "dap-repl", "dapui_watches", "dapui_hover" }

      for _, ft in ipairs(dap_types) do
        cmp.setup.filetype(ft, { sources = {
          { name = "dap" },
        } })
      end
      -- dap repl completion done

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        -- ["<Tab>"] = cmp.mapping(function(fallback)
        --   if cmp.visible() then
        --     cmp.select_next_item()
        --   -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
        --   -- they way you will only jump inside the snippet region
        --   elseif luasnip.expand_or_jumpable() then
        --     luasnip.expand_or_jump()
        --   elseif has_words_before() then
        --     cmp.complete()
        --   else
        --     fallback()
        --   end
        -- end, { "i", "s" }),
        ["<Tab>"] = vim.schedule_wrap(function(fallback)
          if cmp.visible() and has_words_before() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif neogen.jumpable() then
            neogen.jump_next()
          else
            fallback()
          end
        end),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          elseif neogen.jumpable(true) then
            neogen.jump_prev()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-j>"] = cmp.mapping.scroll_docs(-4),
        ["<C-k>"] = cmp.mapping.scroll_docs(4),
        ["<C-a>"] = cmp.mapping.abort(),
      })
      opts.sorting = {
        priority_weight = 2,
        comparators = {
          cmp.config.compare.exact,
          require("copilot_cmp.comparators").prioritize,
          -- Below is the default comparitor list and order for nvim-cmp
          cmp.config.compare.offset,
          -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
          cmp.config.compare.score,
          cmp.config.compare.recently_used,
          cmp.config.compare.locality,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      }
      -- opts.completion.autocomplete = false
    end,
  },
}
