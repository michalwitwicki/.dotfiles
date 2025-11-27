return {
	'ggandor/leap.nvim',
	config = function()
		local leap = require('leap')
		leap.opts.vim_opts['go.ignorecase'] = true

		vim.keymap.set({'n', 'x', 'o'}, '<leader>l', '<Plug>(leap-forward)')
		vim.keymap.set({'n', 'x', 'o'}, '<leader>h', '<Plug>(leap-backward)')
	end
}

