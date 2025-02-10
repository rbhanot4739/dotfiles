local pick = function()
  local refactoring = require("refactoring")
  if LazyVim.pick.picker.name == "telescope" then
    return require("telescope").extensions.refactoring.refactors()
  elseif LazyVim.pick.picker.name == "fzf" then
    local fzf_lua = require("fzf-lua")
    local results = refactoring.get_refactors()

    local opts = {
      fzf_opts = {},
      fzf_colors = true,
      actions = {
        ["default"] = function(selected)
          refactoring.refactor(selected[1])
        end,
      },
    }
    fzf_lua.fzf_exec(results, opts)
  else
    -- local items = { "Option 1", "Option 2", "Option 3" }
    -- local prompt = "Select an option:"
    -- local format = function(item)
    --   return "Formatted: " .. item
    -- end
    -- local kind = "example"
    --
    -- vim.ui.select(items, {
    --   prompt = prompt,
    --   format_item = format,
    --   kind = kind,
    -- }, function(choice)
    --   if choice then
    --     print("You selected: " .. choice)
    --   else
    --     print("No option selected")
    --   end
    -- end)
    -- local results = require("refactoring").get_refactors()
    -- local refactoring = require("refactoring")
    -- vim.ui.select(results, {
    --   prompt = "Refactor >>>>: ",
    --   kind = "example",
    --   format = function(item)
    --     return item.description
    --   end,
    -- }, function(choice)
    --   refactoring.refactor(choice)
    -- end)
    require("refactoring").select_refactor()
  end
end

return {
  "ThePrimeagen/refactoring.nvim",
  keys = {
    {
      "<leader>rs",
      pick,
      mode = { "n", "x", "v" },
      desc = "refactors",
    },
  },
}
