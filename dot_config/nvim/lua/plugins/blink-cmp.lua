return {
  "saghen/blink.cmp",
  opts = function(_, opts)
  opts.keymap = vim.tbl_extend("force", opts.keymap , {
['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>'] = { 'hide', 'fallback' },
      ["<Tab>"] = {
        function(cmp)
          if cmp.is_in_snippet() then
            return cmp.accept()
          else
            return cmp.select_next()
          end
        end,
        "snippet_forward",
        "fallback",
      },
      ['<S-Tab>'] = {'select_prev', 'snippet_backward', 'fallback'},
      ['<CR>'] = {
        function(cmp)
          if require("copilot.suggestion").is_visible() then
            LazyVim.create_undo()
            require("copilot.suggestion").accept()
            return true
          else
            return cmp.accept()
      end
     end,
        "fallback",
    }
    })
  end,
}
