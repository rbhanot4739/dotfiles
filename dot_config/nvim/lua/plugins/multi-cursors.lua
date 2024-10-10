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
      mc.addCursor("*")
    end, { desc = "Add cursor to next match" })

    -- Jump to the next word under cursor but do not add a cursor
    vim.keymap.set({ "n", "v" }, "<M-p>", function()
      mc.skipCursor("*")
    end, { desc = "Do not add cursor to next match" })

    -- Rotate the main cursor.
    vim.keymap.set({ "n", "v" }, "<left>", mc.nextCursor, { desc = "Move to previous cursor" })
    vim.keymap.set({ "n", "v" }, "<right>", mc.prevCursor, { desc = "Move to next cursor" })

    -- Delete the main cursor.
    vim.keymap.set({ "n", "v" }, "<leader>x", mc.deleteCursor)

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
    vim.keymap.set("n", "<leader>a", mc.alignCursors)

    -- Append/insert for each line of visual selections.
    vim.keymap.set("v", "I", mc.insertVisual)
    vim.keymap.set("v", "A", mc.appendVisual)

    -- match new cursors within visual selections by regex.
    vim.keymap.set("v", "M", mc.matchCursors)

    -- Rotate visual selection contents.
    vim.keymap.set("v", "<leader>t", function()
      mc.transposeCursors(1)
    end)
    vim.keymap.set("v", "<leader>T", function()
      mc.transposeCursors(-1)
    end)

    -- Customize how cursors look.
    vim.api.nvim_set_hl(0, "MultiCursorCursor", { link = "Cursor" })
    vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = "Visual" })
    vim.api.nvim_set_hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
    vim.api.nvim_set_hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
  end,
}
