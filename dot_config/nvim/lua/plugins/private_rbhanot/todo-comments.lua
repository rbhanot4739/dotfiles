-- Centralized keyword configuration
local keywords_config = {
  TODO = { "TODO", "Todo", "todo" },
  FIX = { "FIX", "FIXME", "BUG", "FIXIT", "ISSUE", "Fixme", "fixme", "Fixit", "fixit" },
  HACK = { "HACK", "Hack", "hack" },
  NOTE = { "NOTE", "INFO", "Note", "Info", "note" },
  TEST = { "TEST", "TESTING", "PASSED", "FAILED", "Test", "test" },
  TEMP = { "TEMP", "TEMPORARY", "SHORT-TERM", "TRANSIENT", "temp", "Temp" },
}

-- Helper function to get all variants for specific keywords
local function get_keyword_variants(keyword_names)
  local variants = {}
  for _, name in ipairs(keyword_names) do
    if keywords_config[name] then
      vim.list_extend(variants, keywords_config[name])
    end
  end
  return variants
end

return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function(_, opts)
    require("todo-comments").setup(opts)
  end,
  opts = {
    signs = true,
    sign_priority = 8,
    merge_keywords = true,
    keywords = {
      FIX = {
        icon = " ",
        color = "error",
        alt = keywords_config.FIX,
      },
      TODO = { icon = " ", color = "info", alt = keywords_config.TODO },
      HACK = { icon = " ", color = "warning", alt = keywords_config.HACK },
      NOTE = { icon = " ", color = "hint", alt = keywords_config.NOTE },
      TEST = { icon = "⏲ ", color = "test", alt = keywords_config.TEST },
      TEMP = { icon = " ", alt = keywords_config.TEMP },
    },
  },
  keys = {
    {
      "<leader>sT",
      function()
        Snacks.picker.todo_comments()
      end,
      desc = "Todo",
    },
    {
      "<leader>st",
      function()
        local keywords = get_keyword_variants({ "TODO", "FIX" })
        Snacks.picker.todo_comments({ keywords = keywords })
      end,
      desc = "Todo/Fix (all variants)",
    },
  },
}
