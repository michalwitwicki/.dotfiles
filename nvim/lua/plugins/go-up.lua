return {
  'nullromo/go-up.nvim',
  opts = {
    -- affect the behavior of zz
    mapZZ = true,
    -- respect splitkeep setting
    respectSplitkeep = false,
    -- respect scrolloff setting
    respectScrolloff = true,
    -- limit number of virtual lines. See options table
    goUpLimit = nil,
    -- number of offset lines to use when aligning
    alignOffsetLines = { top = 0, bottom = 0 },
  }, -- specify options here
  config = function(_, opts)
    local goUp = require('go-up')
    goUp.setup(opts)
  end,
}
