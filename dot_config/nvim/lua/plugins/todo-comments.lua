return {
  "folke/todo-comments.nvim",
  opts = {
    keywords = {
      FIX = {
        icon = " ",
        color = "error",
        alt = { "FIXME", "BUG", "FIXIT", "ISSUE", "Fixme", "fixme", "Fixit", "fixit" },
      },
      TODO = { icon = " ", color = "info", alt = { "Todo", "todo" } },
      HACK = { icon = " ", color = "warning", alt = { "Hack", "hack" } },
      NOTE = { icon = " ", color = "hint", alt = { "INFO", "Note", "Info", "note" } },
      TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED", "Test", "test" } },
      TEMP = { icon = " ", alt = { "TEMPORARY", "SHORT-TERM", "TRANSIENT", "temp", "Temp" } },
    },
  },
  -- keys = {
  -- },
}
