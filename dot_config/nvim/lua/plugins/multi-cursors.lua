return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  config = function()
    local mc = require("multicursor-nvim")

    mc.setup()

    -- Add cursors above/below the main cursor.
    vim.keymap.set({ "n", "v" }, "<M-Up>", function()
      mc.addCursor("k")
    end, { desc = "Add cursor above" })
    vim.keymap.set({ "n", "v" }, "<M-Down>", function()
      mc.addCursor("j")
    end, { desc = "Add cursor below" })

    -- Add a cursor and jump to the next word under cursor.
    vim.keymap.set({ "n", "v" }, "<M-n>", function()
      mc.matchAddCursor(1)
    end, { desc = "Add cursor to next match" })

    -- Jump to the next word under cursor but do not add a cursor
    vim.keymap.set({ "n", "v" }, "<M-N>", function()
      mc.matchSkipCursor(1)
    end, { desc = "Do not add cursor to next match" })

    vim.keymap.set({ "n", "v" }, "<M-p>", function()
      mc.matchAddCursor(-1)
    end)
    vim.keymap.set({ "n", "v" }, "<M-P>", function()
      mc.matchSkipCursor(-1)
    end)

    vim.keymap.set("n", "<M-x>", function()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      elseif mc.hasCursors() then
        mc.clearCursors()
      else
        -- Default <esc> handler.
      end
    end, { desc = "Close cursors" })

    -- Align cursor columns.
    vim.keymap.set("n", "<A-\\>", mc.alignCursors)

    -- Append/insert for each line of visual selections.
    vim.keymap.set("v", "I", mc.insertVisual)
    vim.keymap.set("v", "A", mc.appendVisual)

    -- Customize how cursors look.
    vim.api.nvim_set_hl(0, "MultiCursorCursor", { link = "Cursor" })
    vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = "Visual" })
    vim.api.nvim_set_hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
    vim.api.nvim_set_hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
  end,
}
