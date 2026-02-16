return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        icons = {
            separator = "->",
        },
        spec = {
            { "<leader>f", group = "find" },
            { "<leader>s", group = "search" },
            { "<leader>b", group = "buffer" },
        },
    },
    keys = {
        {
            "<leader>?",
            function() require("which-key").show({ global = false }) end,
            desc = "Buffer local keymaps",
        },
    },
}
