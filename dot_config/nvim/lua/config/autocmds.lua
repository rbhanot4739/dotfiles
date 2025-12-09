local formatOpts = vim.api.nvim_create_augroup("FormatOpts", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
  group = formatOpts,
  pattern = "*",
  callback = function()
    vim.opt.formatoptions:remove({ "r", "o" })
    -- vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Enable autoformat for specific filetypes
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "lua", "markdown" },
  callback = function()
    vim.b.autoformat = true
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "BlinkCmpMenuOpen",
  callback = function()
    vim.b.copilot_suggestion_hidden = true
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "BlinkCmpMenuClose",
  callback = function()
    vim.b.copilot_suggestion_hidden = false
  end,
})

local disabled_dirs = {
  vim.fn.expand("~") .. "/development/personal/self-learning/python-common/DSA",
}

local function is_disabled_dir(bufnr)
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  for _, dir in ipairs(disabled_dirs) do
    if filepath:find(dir, 1, true) == 1 then
      return true
    end
  end
  return false
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    if is_disabled_dir(bufnr) then
      vim.lsp.inline_completion.enable(false)
      vim.g.sidekick_nes = false
    else
      vim.lsp.inline_completion.enable(true)
      vim.g.sidekick_nes = true
    end
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "qf", "trouble" },
  callback = function()
    vim.b.sidekick_nes = false
  end,
})
