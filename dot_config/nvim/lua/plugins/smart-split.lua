return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  opts = { default_amount = 1 },
  keys = {
    {
      "<C-Left>",
      function()
        require("smart-splits").resize_left()
      end,
      desc = "Smart Resize Left",
    },
    {
      "<C-Down>",
      function()
        require("smart-splits").resize_down()
      end,
      desc = "Smart Resize Down",
    },
    {
      "<C-Up>",
      function()
        require("smart-splits").resize_up()
      end,
      desc = "Smart Rezie Up",
    },
    {
      "<C-Right>",
      function()
        require("smart-splits").resize_right()
      end,
      desc = "Smart Rezie Right",
    },

    -- moving between splits
    {
      "<C-h>",
      function()
        require("smart-splits").move_cursor_left()
      end,
      desc = "Smart Move Left",
    },
    {
      "<C-j>",
      function()
        require("smart-splits").move_cursor_down()
      end,
      desc = "Smart Move Down",
    },
    {
      "<C-k>",
      function()
        require("smart-splits").move_cursor_up()
      end,
      desc = "Smart Move Up",
    },
    {
      "<C-l>",
      function()
        require("smart-splits").move_cursor_right()
      end,
      desc = "Smart Move Right",
    },
    -- -- swapping buffers between windows
    -- {
    --   "<leader><leader>h",
    --   function()
    --     require("smart-splits").swap_buf_left()
    --   end,
    --   desc = "Smart Swap left/right",
    -- },
    -- {
    --   "<leader><leader>j",
    --   function()
    --     require("smart-splits").swap_buf_down()
    --   end,
    -- },
    -- {
    --   "<leader><leader>k",
    --   function()
    --     require("smart-splits").swap_buf_up()
    --   end,
    -- },
    -- {
    --   "<leader><leader>l",
    --   function()
    --     require("smart-splits").swap_buf_right()
    --   end,
    -- },
  },
}
