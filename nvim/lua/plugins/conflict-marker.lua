return {
  'rhysd/conflict-marker.vim',
  config = function()
    -- disable the default highlight group
    vim.g.conflict_marker_highlight_group = ''

    -- Include text after begin and end markers
    vim.g.conflict_marker_begin = '^<<<<<<<\\+ .*$'
    vim.g.conflict_marker_common_ancestors = '^|||||||\\+ .*$'
    vim.g.conflict_marker_end = '^>>>>>>>\\+ .*$'
    vim.g.conflict_marker_enable_mappings = 0

    -- Highlight groups
    vim.cmd [[
    highlight ConflictMarkerBegin guibg=#2f7366
    highlight ConflictMarkerOurs guibg=#2e5049
    highlight ConflictMarkerTheirs guibg=#344f69
    highlight ConflictMarkerEnd guibg=#2f628e
    highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81
    ]]
  end
}
