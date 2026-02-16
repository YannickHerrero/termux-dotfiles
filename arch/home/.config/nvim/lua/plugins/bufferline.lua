return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
        options = {
            diagnostics = "nvim_lsp",
            offsets = {
                {
                    filetype = "neo-tree",
                    text = "File Explorer",
                    highlight = "Directory",
                    separator = true,
                },
            },
            separator_style = "thin",
            show_buffer_close_icons = false,
            show_close_icon = false,
        },
        highlights = require("catppuccin.groups.integrations.bufferline").get(),
    },
    keys = {
        { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Pin buffer" },
        { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
    },
}
