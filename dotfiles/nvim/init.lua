require("vim._core.ui2").enable({})

require("options")
require("keymaps")
require("commands")
require("pack")
require("explorer")
require("treesitter")
require("lsp")

local theme_file = vim.fn.expand("~/.config/theme/current/theme/nvim.lua")
if vim.fn.filereadable(theme_file) == 1 then
  dofile(theme_file)
else
  vim.cmd.colorscheme("catppuccin")
end
