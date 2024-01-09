return {
    'dhananjaylatkar/cscope_maps.nvim',
    config = function()
        require('cscope_maps').setup({
            disable_maps = false, -- true disables my keymaps, only :Cscope will be loaded
            skip_input_prompt = true, -- "true" doesn't ask for input
            prefix = "<leader>c", -- prefix to trigger maps
            cscope = {
                db_file = "./cscope.out", -- location of cscope db file
                exec = "cscope", -- "cscope" or "gtags-cscope"
                picker = "telescope", -- "telescope", "fzf-lua" or "quickfix"
                qf_window_size = 5, -- any positive integer
                qf_window_pos = "bottom", -- "bottom", "right", "left" or "top"
                skip_picker_for_single_result = true, -- jump directly to position for single result
                db_build_cmd_args = { "-bqkvR" }, -- args used for db build (:Cscope build)
                statusline_indicator = nil,
            },
        })
    end
}


-- Default Keymaps
-- <prefix>s	find all references to the token under cursor
-- <prefix>g	find global definition(s) of the token under cursor
-- <prefix>c	find all calls to the function name under cursor
-- <prefix>t	find all instances of the text under cursor
-- <prefix>e	egrep search for the word under cursor
-- <prefix>f	open the filename under cursor
-- <prefix>i	find files that include the filename under cursor
-- <prefix>d	find functions that function under cursor calls
-- <prefix>a	find places where this symbol is assigned a value
-- <prefix>b	build cscope database
-- Ctrl-]	do :Cstag <cword>
