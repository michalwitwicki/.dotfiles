return {
    "sphamba/smear-cursor.nvim",
    opts = {
        -- Smear cursor color. Defaults to Cursor GUI color if not set.
        -- Set to "none" to match the text color at the target cursor position.
        -- cursor_color = "#d3cdc3",
        cursor_color = "#ff8800",

        -- Background color. Defaults to Normal GUI background color if not set.
        normal_bg = "#282828",

        -- Smear cursor when switching buffers or windows.
        smear_between_buffers = true,

        -- Smear cursor when moving within line or to neighbor lines.
        smear_between_neighbor_lines = true,

        -- Set to `true` if your font supports legacy computing symbols (block unicode symbols).
        -- Smears will blend better on all backgrounds.
        legacy_computing_symbols_support = false,

        -- How fast the smear's head moves towards the target.
        -- 0: no movement, 1: instantaneous
        -- stiffness = 0.6,
        stiffness = 0.5,
    },
}
