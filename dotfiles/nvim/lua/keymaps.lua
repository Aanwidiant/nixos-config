vim.g.mapleader = " "

vim.keymap.set("x", "p", [["-dP"]], {desc = "Paste over selection whitout losing yanked text" })

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d"]], { desc = "Delete without yanking" })

vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Exit" })
vim.keymap.set("n", "<C-c>", ":nohl<CR>", {desc = "Clear search highlighting", silent = true})

vim.keymap.set("n", "<C-s>", ":w<CR>", { silent = true, desc = "Save from normal mode" })
vim.keymap.set("i", "<C-s>", "<Esc>:w<Esc>", { silent = true, desc = "Save and continue insert next"})

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", {desc = "move lines down in visual selection"})
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", {desc = "move lines up in visual selection"})

vim.keymap.set("v", "<", "<gv", {desc = "Unindent and keep selection"})
vim.keymap.set("v", ">", ">gv", {desc = "Indent and keep selection"})

vim.keymap.set("n", "J", "mzJ`z", {desc = "Join lines without moving cursor"})

vim.keymap.set("n", "<C-d>", "<C-d>zz", {desc = "move down in buffer with cursor centered"})
vim.keymap.set("n", "<C-u>", "<C-u>zz", {desc = "move up in buffer with cursor centered"})

vim.keymap.set("n", "n", "nzzzv", {desc = "Next search result cursor centered"})
vim.keymap.set("n", "N", "Nzzzv", {desc = "Previous search result cursor centered"})

vim.keymap.set("n", "<leader>cx", "<cmd>!chmod +x %<CR>", {silent = true, desc = "Make file executable"})

vim.keymap.set("n", "<leader>/", "gcc", { desc = "Toggle comment", remap = true })
vim.keymap.set("v", "<leader>/", "gc", { desc = "Toggle comment", remap = true })

vim.keymap.set("n", "<leader>u", function()
    vim.cmd.packadd("nvim.undotree")
    require("undotree").open()
end, {desc = "Toggle built-in undotree"})

vim.keymap.set("n", "<leader>ob", function()
    local file = vim.api.nvim_buf_get_name(0)
    if vim.bo.filetype ~= "html" then
        vim.notify("Bukan file HTML", vim.log.levels.WARN)
        return
    end
    vim.fn.jobstart({ "xdg-open", file }, { detach = true })
end, { desc = "Open HTML in browser" })

vim.keymap.set({ "i", "s" }, "<C-l>", function()
  require("mini.snippets").unlink_current()
end)

-- block keybind
vim.keymap.set("n", "<C-z>", "<Nop>")
vim.keymap.set("i", "<C-z>", "<Nop>")
