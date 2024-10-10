return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    -- "f3fora/cmp-spell",
    "rcarriga/cmp-dap",
    "hrsh7th/cmp-cmdline",
  },
  ---@param opts cmp.ConfigSchema
  opts = function(_, opts)
    local has_words_before = function()
      unpack = unpack or table.unpack
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    -- insert copilot completions after lsp
    table.remove(opts.sources, 1)
    table.insert(opts.sources, { name = "copilot",
      group_index = 2,
      priority = 100,
    })
    local cmp = require("cmp")
    -- --------------------------------------cmdline setup start-----------------------------------------------------------------------------------------------------
    -- `/` cmdline setup.
    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })
    -- `:` cmdline setup.
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
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
    -- --------------------------------------cmdline setup done-----------------------------------------------------------------------------------------------------
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
    -- table.insert(opts.sources, {
    --   name = "spell",
    --   option = {
    --     keep_all_entries = false,
    --     enable_in_context = function()
    --       return true
    --     end,
    --     preselect_correct_word = true,
    --   },
    --   group_index = 3,
    --   priority = 100,
    -- })

    opts.mapping = vim.tbl_extend("force", opts.mapping, {
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          -- You could replace select_next_item() with confirm({ select = true }) to get VS Code autocompletion behavior
          cmp.select_next_item()
        elseif vim.snippet.active({ direction = 1 }) then
          vim.schedule(function()
            vim.snippet.jump(1)
          end)
        elseif has_words_before() then
          -- cmp.complete()
          cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif vim.snippet.active({ direction = -1 }) then
          vim.schedule(function()
            vim.snippet.jump(-1)
          end)
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<C-j>"] = cmp.mapping.scroll_docs(-4),
      ["<C-k>"] = cmp.mapping.scroll_docs(4),
    })
  end,
}
