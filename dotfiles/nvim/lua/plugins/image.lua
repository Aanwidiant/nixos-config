return {
  {
    "3rd/image.nvim",
    dependencies = {
      {
        "vhyrro/luarocks.nvim",
        priority = 1000,
        config = true,
      },
    },
    opts = {
      backend = "kitty",
      max_width_window_percentage = 80,
      max_height_window_percentage = 50,
      x = 10,
      y = 2,
      integrations = {
        markdown = { enabled = true },
        neorg = { enabled = true },
      },
    },
  },
}
