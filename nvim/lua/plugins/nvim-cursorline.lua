return {
    'yamatsum/nvim-cursorline',
    config = function()
        require('nvim-cursorline').setup {
            cursorline = {
                enable = true,
                timeout = 1000,
                number = false,
            },
            cursorword = {
                enable = true,
                min_length = 2,
                hl = { underline = true },
            }
        }
    end
}
