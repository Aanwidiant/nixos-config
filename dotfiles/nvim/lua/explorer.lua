vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local nvim_tree_api = require("nvim-tree.api")

local image_exts = { png = true, jpg = true, jpeg = true, gif = true, webp = true }

local function smart_open(node)
    if not node then return end

    if node.type == "directory" then
        nvim_tree_api.node.open.edit()
        return
    end

    local ext = node.name:match("%.(%w+)$")
    if ext and image_exts[ext:lower()] then
        vim.fn.jobstart({ "imv", node.absolute_path }, { detach = true })
    else
        nvim_tree_api.node.open.edit()
    end
end

local function open_svg_as_image(node)
    if not node or node.type == "directory" then return end

    local ext = node.name:match("%.(%w+)$")
    if ext and ext:lower() == "svg" then
        vim.fn.jobstart({ "imv", node.absolute_path }, { detach = true })
    end
end

local function xdg_open(node)
    if not node or node.type == "directory" then return end
    vim.ui.open(node.absolute_path)
end

local function on_attach(bufnr)
    local opts = function(desc)
        return {
            desc = "nvim-tree: " .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true,
        }
    end

    nvim_tree_api.map.on_attach.default(bufnr)

    vim.keymap.set("n", "l", function()
        local node = nvim_tree_api.tree.get_node_under_cursor()
        smart_open(node)
    end, opts("Open / Enter"))

    vim.keymap.set("n", "h", function()
        local node = nvim_tree_api.tree.get_node_under_cursor()
        if node and node.type == "directory" and node.open then
            nvim_tree_api.node.navigate.parent_close()
        else
            nvim_tree_api.node.navigate.parent()
        end
    end, opts("Collapse / Go to parent"))

    vim.keymap.set("n", "<CR>", function()
        local node = nvim_tree_api.tree.get_node_under_cursor()
        smart_open(node)
    end, opts("Smart open"))

    vim.keymap.set("n", "go", function()
        local node = nvim_tree_api.tree.get_node_under_cursor()
        xdg_open(node)
    end, opts("xdg-open"))

    vim.keymap.set("n", "i", function()
        local node = nvim_tree_api.tree.get_node_under_cursor()
        open_svg_as_image(node)
    end, opts("Open SVG as Image (imv)"))
end

require("nvim-tree").setup({
    on_attach = on_attach,

    disable_netrw = true,
    hijack_netrw = true,

    sort = {
        sorter = "case_sensitive",
    },

    view = {
        width = 32,
        side = "left",
        preserve_window_proportions = true,
    },

    renderer = {
        group_empty = false,
        highlight_git = true,
        highlight_opened_files = "name",
        icons = {
            show = {
                file = true,
                folder = true,
                folder_arrow = true,
                git = false,
            },
        },
    },

    filters = {
        dotfiles = false,
        git_ignored = false,
        custom = {
            "^.git$",
        },
    },

    git = {
        enable = true,
        ignore = false,
        timeout = 400,
    },

    diagnostics = {
        enable = true,
        show_on_dirs = true,
    },

    filesystem_watchers = {
        enable = true,
    },

    actions = {
        open_file = {
            quit_on_open = false,
            resize_window = false,
            window_picker = {
                enable = true,
                chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
            },
        },
    },
})

vim.keymap.set("n", "<leader>e", function()
    nvim_tree_api.tree.toggle({ focus = true, find_file = true })
end, { desc = "Toggle file tree" })

vim.keymap.set("n", "<leader>E", function()
    nvim_tree_api.tree.find_file({ open = true, focus = true })
end, { desc = "Reveal current file in tree" })
