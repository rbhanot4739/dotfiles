local keymap = vim.keymap.set
local opts = {
  noremap = true,
  silent = true,
}

keymap("n", "<Space>", "", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

keymap("n", "U", "<cmd>lua require('vscode').action('redo')<CR>", opts)

keymap("n", "gh", "<cmd>lua require('vscode').action('cursorHome')<CR>", opts)
keymap("n", "gl", "<cmd>lua require('vscode').action('cursorEnd')<CR>", opts)

keymap("n", "Y", "<cmd>lua require('vscode').action('editor.action.clipboardCopyAction')<CR>", opts)

-- Search navigation with centering (n/N)
keymap("n", "n", "<cmd>lua require('vscode').action('editor.action.nextMatchFindAction')<CR>", opts)
keymap("n", "N", "<cmd>lua require('vscode').action('editor.action.previousMatchFindAction')<CR>", opts)

-- EDITOR-FOCUSED SEARCH OPERATIONS

-- Search word under cursor
keymap(
  { "n", "v" },
  "<leader>sw",
  "<cmd>lua require('vscode').action('editor.action.addSelectionToNextFindMatch')<CR>",
  opts
)
keymap({ "n", "v" }, "<leader>sW", "<cmd>lua require('vscode').action('actions.find')<CR>", opts)

-- Search symbols
keymap({ "n", "v" }, "<leader>ss", "<cmd>lua require('vscode').action('workbench.action.gotoSymbol')<CR>", opts)

-- Spell suggest
keymap({ "n", "v" }, "<leader>=", "<cmd>lua require('vscode').action('editor.action.quickFix')<CR>", opts)

-- ============================================================================
-- LSP/CODE OPERATIONS (SPACE + C PREFIX)
-- ============================================================================

-- Code actions
keymap({ "n", "v" }, "<leader>ca", "<cmd>lua require('vscode').action('editor.action.quickFix')<CR>", opts)

-- Format document
keymap({ "n", "v" }, "<leader>cf", "<cmd>lua require('vscode').action('editor.action.formatDocument')<CR>", opts)

-- Rename symbol
keymap({ "n", "v" }, "<leader>cr", "<cmd>lua require('vscode').action('editor.action.rename')<CR>", opts)

-- Show hover
keymap("n", "K", "<cmd>lua require('vscode').action('editor.action.showHover')<CR>", opts)

-- Go to definition
keymap("n", "gd", "<cmd>lua require('vscode').action('editor.action.revealDefinition')<CR>", opts)

-- Go to references
keymap("n", "gr", "<cmd>lua require('vscode').action('editor.action.goToReferences')<CR>", opts)

-- AI Chat
keymap(
  { "n", "v" },
  "<leader>cc",
  "<cmd>lua require('vscode').action('github.copilot.interactiveEditor.explain')<CR>",
  opts
)

-- AI inline chat
keymap({ "n", "v" }, "<leader>ci", "<cmd>lua require('vscode').action('inlineChat.start')<CR>", opts)

-- ============================================================================
-- DEBUGGING (SPACE + D PREFIX)
-- ============================================================================

-- Toggle breakpoint
keymap(
  { "n", "v" },
  "<leader>db",
  "<cmd>lua require('vscode').action('editor.debug.action.toggleBreakpoint')<CR>",
  opts
)

-- ============================================================================
-- TESTING (SPACE + T PREFIX)
-- ============================================================================

-- Run nearest test
keymap({ "n", "v" }, "<leader>tr", "<cmd>lua require('vscode').action('test-explorer.run-test-at-cursor')<CR>", opts)

-- Debug nearest test
keymap({ "n", "v" }, "<leader>td", "<cmd>lua require('vscode').action('test-explorer.debug-test-at-cursor')<CR>", opts)

-- ============================================================================
-- MULTI-CURSOR
-- ============================================================================

-- Add cursor above/below
keymap("n", "<M-Up>", "<cmd>lua require('vscode').action('editor.action.insertCursorAbove')<CR>", opts)
keymap("n", "<M-Down>", "<cmd>lua require('vscode').action('editor.action.insertCursorBelow')<CR>", opts)

-- Add cursor to next match
keymap("n", "<M-n>", "<cmd>lua require('vscode').action('editor.action.addSelectionToNextFindMatch')<CR>", opts)

-- Close cursors
keymap("n", "<M-x>", "<cmd>lua require('vscode').action('cursorUndo')<CR>", opts)

-- ============================================================================
-- FLASH/JUMP NAVIGATION
-- ============================================================================

-- Flash search
keymap("n", "s", "<cmd>lua require('vscode').action('extension.vim_easymotion')<CR>", opts)

-- ============================================================================
-- REFACTORING (SPACE + R PREFIX)
-- ============================================================================

-- Extract function
keymap({ "n", "v" }, "<leader>rf", "<cmd>lua require('vscode').action('editor.action.refactor')<CR>", opts)

-- Inline variable
keymap({ "n", "v" }, "<leader>ri", "<cmd>lua require('vscode').action('editor.action.refactor')<CR>", opts)

-- ============================================================================
-- CUSTOM NEOVIM MAPPINGS & LEGACY MAPPINGS
-- ============================================================================

-- Fold toggle
keymap("n", "<CR>", "<cmd>lua require('vscode').action('editor.toggleFold')<CR>", opts)

-- Disable arrow keys
keymap("n", "<Up>", "<Nop>", opts)
keymap("n", "<Down>", "<Nop>", opts)
keymap("n", "<Left>", "<Nop>", opts)
keymap("n", "<Right>", "<Nop>", opts)

-- ============================================================================
-- EXISTING/LEGACY KEYMAPS (PRESERVED FOR COMPATIBILITY)
-- ============================================================================

-- general keymaps
keymap({ "n", "v" }, "<leader>b", "<cmd>lua require('vscode').action('editor.debug.action.toggleBreakpoint')<CR>", opts) -- Legacy: same as <leader>db
keymap({ "n", "v" }, "<leader>d", "<cmd>lua require('vscode').action('editor.action.showHover')<CR>", opts) -- Legacy: same as K
keymap({ "n", "v" }, "<leader>a", "<cmd>lua require('vscode').action('editor.action.quickFix')<CR>", opts) -- Legacy: same as <leader>ca
keymap({ "n", "v" }, "<leader>pr", "<cmd>lua require('vscode').action('code-runner.run')<CR>", opts) -- Legacy: code runner
keymap({ "n", "v" }, "<leader>fd", "<cmd>lua require('vscode').action('editor.action.formatDocument')<CR>", opts) -- Legacy: same as <leader>cf
