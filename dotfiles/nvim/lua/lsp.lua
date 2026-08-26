require("mason").setup()

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

vim.diagnostic.config({
    virtual_text = true
})

vim.keymap.set("n", "<leader>f", function()
    local cwd = vim.fn.getcwd() .. ";"
    local biome = vim.fn.findfile("biome.json", cwd)
    local prettier = vim.fn.findfile(".prettierrc", cwd) ~= "" and vim.fn.findfile(".prettierrc", cwd)
        or vim.fn.findfile("prettier.config.js", cwd) ~= "" and vim.fn.findfile("prettier.config.js", cwd)
        or vim.fn.findfile("prettier.config.ts", cwd) ~= "" and vim.fn.findfile("prettier.config.ts", cwd)
        or ""
    local ft = vim.bo.filetype

    if ft == "nix" and vim.fn.executable("nixpkgs-fmt") == 1 then
        vim.cmd("silent !nixpkgs-fmt " .. vim.fn.expand("%"))
        vim.cmd("edit")
    elseif biome ~= "" then
        vim.cmd("silent !biome format --write " .. vim.fn.expand("%"))
        vim.cmd("edit")
    elseif prettier ~= "" then
        vim.cmd("silent !prettier --write " .. vim.fn.expand("%"))
        vim.cmd("edit")
    else
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        local has_formatter = false
        for _, client in ipairs(clients) do
            if client:supports_method("textDocument/formatting") then
                has_formatter = true
                break
            end
        end
        if has_formatter then
            vim.lsp.buf.format({ async = true })
        else
            vim.cmd("normal! gg=G")
        end
    end
end, { desc = "Format buffer (biome > prettier > lsp)" })

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("mini.completion").get_lsp_capabilities())
vim.lsp.config("*", { capabilities = capabilities })

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } },
        },
    },
})

vim.lsp.config("ts_ls", {
    settings = {
        typescript = {
            inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayReturnTypeHints = true,
            },
        },
        javascript = {
            inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayReturnTypeHints = true,
            },
        },
    },
})

vim.lsp.config("emmet_language_server", {
    filetypes = {
        "html", "css", "eruby", "htmldjango",
        "javascriptreact", "typescriptreact",
        "less", "pug", "sass", "scss",
        "jsx", "tsx",
    },
})

if vim.fn.executable("nixd") == 1 then
    vim.lsp.enable("nixd")
end

vim.lsp.enable({
    "lua_ls",
    "ts_ls",
    "html",
    "cssls",
    "jsonls",
    "tailwindcss",
    "prismals",
    "pyright",
    "rust_analyzer",
    "dockerls",
    "yamlls",
    "emmet_language_server",
    "qmlls"
})
