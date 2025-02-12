local M = {}
-- Boolean = " ",
-- Constant = " ",
-- Interface = " ",
M.icons = {
  kinds = {
    Array = " ",
    Boolean = "󰨙 ",
    Class = " ",
    Codeium = "󰘦 ",
    Color = "󰏘 ",
    Control = " ",
    Collapsed = " ",
    Constant = "󰏿 ",
    -- Constructor = " ",
    Constructor = " ",
    Copilot = " ",
    -- Enum = " ",
    Enum = " ",
    -- EnumMember = " ",
    EnumMember = " ",
    Event = " ",
    -- Field = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    -- Function = "󰊕 ",
    Function = " ",
    Interface = " ",
    Key = " ",
    Keyword = "󰻾 ",
    -- Method = "󰊕 ",
    Method = " ",
    -- Module = " ",
    Module = " ",
    Namespace = "󰦮 ",
    Null = " ",
    Number = "󰎠 ",
    Object = " ",
    Operator = "󰪚 ",
    Package = " ",
    -- Package = " ",
    -- Property = " ",
    Property = " ",
    Reference = " ",
    Snippet = "󱄽 ",
    String = " ",
    -- Struct = "󰆼 ",
    Struct = " ",
    TabNine = "󰏚 ",
    Text = "󰉿 ",
    Unit = " ",
    TypeParameter = "󰬛",
    -- Value = " ",
    Value = " ",
    Variable = " ",
  },
}

function M.my_picker(opts)
  local Finder = require("snacks.picker.core.finder")
  local Picker = require("snacks.picker.core.picker")
  opts = opts or {}

  -- Define the items to be displayed in the picker
  local items = {
    { id = 0, text = "Item 3" },
    { id = 1, text = "Item 2" },
    { id = 2, text = "Item 1" },
  }

  -- Create a new finder
  local finder = Finder.new(function()
    return items
  end)

  -- Create a new picker
  local picker = Picker.new({
    title = "My Picker",
    items = items,
    layout = { preview = false, preset = "dropdown" },
    format = "text",
    attach_mappings = function(prompt_bufnr, map)
      -- Define custom mappings here
      return true
    end,
  })

  -- Show the picker
  picker:show()
end

return M
