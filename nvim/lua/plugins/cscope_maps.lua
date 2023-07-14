-- load cscope maps
-- pass empty table to setup({}) for default options
require('cscope_maps').setup({
    disable_maps = false, -- true disables my keymaps, only :Cscope will be loaded
    skip_input_prompt = true, -- "true" doesn't ask for input
    cscope = {
        db_file = "./cscope.out", -- location of cscope db file
        exec = "cscope", -- "cscope" or "gtags-cscope"
        picker = "telescope", -- "telescope", "fzf-lua" or "quickfix"
        skip_picker_for_single_result = true, -- jump directly to position for single result
        db_build_cmd_args = { "-bqkvR" }, -- args used for db build (:Cscope build)
    },
})


-- Default Keymaps
-- Keymaps	Description
-- <leader>cs	find all references to the token under cursor
-- <leader>cg	find global definition(s) of the token under cursor
-- <leader>cc	find all calls to the function name under cursor
-- <leader>ca	find places where this symbol is assigned a value
-- <leader>cb	build cscope database
-- <leader>cf	open the filename under cursor
-- <leader>ci	find files that include the filename under cursor
-- <leader>cd	find functions that function under cursor calls

-- Ctrl-]	do :Cstag <cword>
-- <leader>ct	find all instances of the text under cursor
-- <leader>ce	egrep search for the word under cursor
