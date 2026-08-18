local treesitter = require("nvim-treesitter")

local ensure_installed = {
    -- web
    "typescript", "javascript", "tsx", "jsx",
    "html", "css", "json",
    -- fullstack
    "prisma", "graphql", "sql",
    -- devops / config
    "dockerfile", "nix", "yaml", "toml",
    -- docs
    "markdown", "markdown_inline",
    -- languages
    "python", "rust", "go",
    -- shell
    "bash",
    -- built-in  
    "lua", "vim", "vimdoc", "query", "regex", "c",
}

treesitter.install(ensure_installed)

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
        local buf = args.buf
        local ft = vim.bo[buf].filetype

        local lang = vim.treesitter.language.get_lang(ft)
        if not lang then
            return
        end

        local ok_add = pcall(vim.treesitter.language.add, lang)
        if not ok_add then
            return
        end

        pcall(vim.treesitter.start, buf, lang)
    end,
})
