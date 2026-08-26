vim.pack.add({
    "https://github.com/nvim-mini/mini.nvim",
    "https://github.com/rafamadriz/friendly-snippets",
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/tpope/vim-fugitive",
    "https://github.com/nvim-tree/nvim-tree.lua",
    "https://github.com/folke/tokyonight.nvim",
    "https://github.com/shaunsingh/nord.nvim",
    "https://github.com/mofiqul/dracula.nvim",
    "https://github.com/morhetz/gruvbox",
    "https://github.com/folke/persistence.nvim",
})

---- project management ----
local startup_root = vim.uv.cwd() or vim.fn.getcwd()
local project_history_file = vim.fn.stdpath("data") .. "/projects"

local function save_project()
    local projects = {}

    if vim.fn.filereadable(project_history_file) == 1 then
        projects = vim.fn.readfile(project_history_file)
    end

    local filtered = { startup_root }

    for _, project in ipairs(projects) do
        if project ~= startup_root then
            table.insert(filtered, project)
        end
    end

    while #filtered > 20 do
        table.remove(filtered)
    end

    vim.fn.writefile(filtered, project_history_file)
end

save_project()

---- mini notify ----
require("mini.notify").setup({
    content = {
        format = function(notif)
            return notif.msg
        end,
    },
})

---- mini cmdline completion ----
require("mini.cmdline").setup({
    autocorrect = { enable = false }
})

---- mini surround ----
require("mini.surround").setup()

---- mini icons ----
local MiniIcons = require("mini.icons")
MiniIcons.setup()
MiniIcons.mock_nvim_web_devicons()

---- mini pairs ----
require("mini.pairs").setup()

---- mini picker  ----
local MiniPick = require("mini.pick")
local MiniExtra = require("mini.extra")

---- terminal ----
local terminal_buf = nil
local terminal_win = nil

local function toggle_terminal()
    if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
        vim.api.nvim_win_hide(terminal_win)
        terminal_win = nil
        return
    end

    vim.cmd("botright 15split")
    terminal_win = vim.api.nvim_get_current_win()

    if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
        vim.api.nvim_win_set_buf(terminal_win, terminal_buf)
    else
        terminal_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(terminal_win, terminal_buf)
        vim.fn.termopen(os.getenv("SHELL") or "/bin/bash", {
            cwd = startup_root,
            on_exit = function()
                terminal_buf = nil
                terminal_win = nil
            end,
        })
    end

    vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>t", toggle_terminal, { desc = "Toggle terminal" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("t", "<leader>t", function()
    vim.api.nvim_win_hide(terminal_win)
    terminal_win = nil
end, { desc = "Hide terminal" })

---- project picker functions ----
local nvim_tree_api = require("nvim-tree.api")
local function recent_projects()
    if vim.fn.filereadable(project_history_file) == 0 then
        vim.notify("No recent projects")
        return
    end

    local projects = vim.fn.readfile(project_history_file)

    MiniPick.start({
        source = {
            name = "Recent Projects",
            items = projects,
            choose = function(path)
                vim.fn.chdir(path)
                startup_root = path
                nvim_tree_api.tree.change_root(path)
                if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
                    vim.api.nvim_buf_delete(terminal_buf, { force = true })
                end
                terminal_buf = nil
                terminal_win = nil

                save_project()
                vim.notify("Switched to:\n" .. path)
            end,
        },
    })
end

local function remove_recent_project()
    if vim.fn.filereadable(project_history_file) == 0 then
        vim.notify("No recent projects")
        return
    end

    local projects = vim.fn.readfile(project_history_file)

    MiniPick.start({
        source = {
            name = "Remove Recent Project",
            items = projects,
            choose = function(path)
                local filtered = {}

                for _, project in ipairs(projects) do
                    if project ~= path then
                        table.insert(filtered, project)
                    end
                end

                vim.fn.writefile(filtered, project_history_file)
                vim.notify("Removed:\n" .. path)
            end,
        },
    })
end

local function git_changes_picker()
    local is_git = vim.fn.trim(vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"))
    if is_git ~= "true" then
        vim.notify("Not a git repository", vim.log.levels.WARN)
        return
    end

    local handle = io.popen("git diff --numstat")
    if not handle then
        vim.notify("Failed to run git diff", vim.log.levels.ERROR)
        return
    end

    local result = handle:read("*a")
    handle:close()

    if result == "" then
        vim.notify("No unstaged changes")
        return
    end

    local items = {}

    for line in result:gmatch("[^\r\n]+") do
        local added, removed, file = line:match("(%d+)%s+(%d+)%s+(.+)")
        if file then
            table.insert(items, {
                file = file,
                added = tonumber(added) or 0,
                removed = tonumber(removed) or 0,
            })
        end
    end

    require('mini.pick').start({
        source = {
            name = "Git Changes (+/- lines)",

            items = items,

            format = function(item)
                return string.format(
                    "%s   +%d -%d",
                    item.file,
                    item.added,
                    item.removed
                )
            end,

            choose = function(item)
                vim.cmd("edit " .. item.file)
            end,
        },
    })
end

MiniPick.setup()

vim.keymap.set("n", "<leader>pf", function() MiniPick.builtin.files() end, { desc = "Mini File Picker" })
vim.keymap.set("n", "<leader>ps", function()
    MiniPick.builtin.grep_live({
        args = {
            "--hidden",
            "--glob=!**/.git/*",
        },
    })
end, { desc = "Live grep" })

vim.keymap.set("n", "<leader>sw", function()
    MiniPick.builtin.grep({
        pattern = vim.fn.expand("<cword>")
    })
end, { desc = "Search word under cursor" })
vim.keymap.set("n", "<leader>vh", function() MiniPick.builtin.help() end, { desc = "Mini help" })
vim.keymap.set("n", "<leader>pb", function() MiniPick.builtin.buffers() end, { desc = "Search buffers" })
vim.keymap.set("n", "<leader>pr", recent_projects, { desc = "Recent projects" })
vim.keymap.set("n", "<leader>pd", remove_recent_project, {
    desc = "Delete project from recent",
})
vim.keymap.set("n", "<leader>pg", git_changes_picker, {
    desc = "Git changes picker (+/- lines)"
})

vim.keymap.set("n", "<leader>xx", function() MiniExtra.pickers.diagnostic() end, { desc = "Mini Picker Diagnostics" })
vim.keymap.set("n", "<leader>pk", function() MiniExtra.pickers.keymaps() end, { desc = "Search keymaps" })

---- mini completions ----
require("mini.completion").setup({
    lsp_completion = {
        auto_setup = true,
    }
})

---- mini snippets ----
local MiniSnippets = require("mini.snippets")
MiniSnippets.setup({
    snippets = {
        MiniSnippets.gen_loader.from_lang(),
    },
})
MiniSnippets.start_lsp_server({ match = false })

---- mini diff ----
local MiniDiff = require("mini.diff")
MiniDiff.setup({
    source = MiniDiff.gen_source.git({ index = false }),
})

vim.keymap.set("n", "<leader>gg", "<cmd>tabnew | Git | only<cr>", { desc = "Fugitive full page new tab" })
vim.keymap.set("n", "<leader>gd", "<cmd>Gvdiffsplit<CR>", { desc = "Git diff split" })
vim.keymap.set("n", "<leader>gb", function()
    local wins = vim.api.nvim_list_wins()
    for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "fugitiveblame" then
            vim.api.nvim_win_close(win, true)
            return
        end
    end
    vim.cmd("Git blame")
end, { desc = "Toggle git blame" })

---- mini statusline ----
local git_branch = ""
local function update_branch()
    git_branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
end
update_branch()

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
    callback = update_branch,
})

require('mini.statusline').setup({
    use_icons = false,
    content = {
        active = function()
            local MiniStatusline = require('mini.statusline')
            local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
            local filename = MiniStatusline.section_filename({ trunc_width = 140 })
            mode = string.upper(mode)
            local location = " " .. "%l:%c" .. " "
            local clock = " " .. os.date("%H:%M") .. " "

            local branch_str = git_branch ~= "" and ("  " .. git_branch .. " ") or ""

            return MiniStatusline.combine_groups({
                { hl = mode_hl,      strings = { " " .. mode .. " " } },
                { hl = "StatusLine", strings = { " " .. filename .. " " } },
                "%=",
                { hl = "MiniStatuslineModeNormal", strings = { branch_str } },
                { hl = "MiniStatuslineModeInsert", strings = { location } },
                { hl = "MiniStatuslineModeNormal", strings = { "%p%%" } },
                { hl = "MiniStatuslineModeInsert", strings = { clock } },
            })
        end,
    },
})

---- mini tabline ----
require('mini.tabline').setup({
    show_icons = true,
    format = function(buf_id, label)
        local modified = vim.bo[buf_id].modified and " ●" or ""
        local icon, _ = MiniIcons.get("file", label)
        return "  " .. icon .. " " .. label .. modified .. "  "
    end,
})

---- mini indentscope ----
require('mini.indentscope').setup({
    draw = {
        animation = require('mini.indentscope').gen_animation.none(),
    },

    symbol = '│',

    options = {
        try_as_border = true,
    },
})

---- buffer ----
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", {
    desc = "Next Buffer",
})

vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", {
    desc = "Previous Buffer",
})

local bufremove = require("mini.bufremove")

vim.keymap.set("n", "<leader>bd", function()
    bufremove.delete(0, false)
end, {
    desc = "Delete Buffer",
})

vim.keymap.set("n", "<leader>bD", function()
    local bufs = vim.api.nvim_list_bufs()
    for _, buf in ipairs(bufs) do
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
            bufremove.delete(buf, false)
        end
    end
end, { desc = "Delete All Buffers" })


---- sessionoptions ----
vim.opt.sessionoptions = { "buffers", "curdir", "folds", "help", "tabpages", "winsize", "winpos", "terminal" }

---- persistence setup ----
require("persistence").setup({
    dir = vim.fn.stdpath("state") .. "/sessions/",
    options = { "buffers", "curdir", "folds", "tabpages", "winsize" },
})

vim.keymap.set("n", "<leader>qs", function()
    require("persistence").load()
end, { desc = "Restore Session (Current Directory)" })

vim.keymap.set("n", "<leader>ql", function()
    require("persistence").load({ last = true })
end, { desc = "Restore Last Session" })

vim.keymap.set("n", "<leader>qd", function()
    require("persistence").stop()
end, { desc = "Stop Session Persistence (Don't Save)" })
