#!/usr/bin/env bash
#
# Comprehensive terminal capabilities test script.
# Tests: 16/256/truecolor, SGR attributes, SGR reset verification,
# Unicode & wide characters, alternate screen buffer, mouse reporting,
# and Sixel/Kitty image protocol.

set -u

# ─── helpers ────────────────────────────────────────────────────────────────

section() {
  printf '\n\x1b[1;4;36m=== %s ===\x1b[0m\n\n' "$1"
}

# Read a single terminal response with a timeout.
# Usage: response=$(read_response [timeout_secs])
read_response() {
  local timeout=${1:-1}
  local buf=""
  local char
  while IFS= read -r -s -n1 -t "$timeout" char; do
    buf+="$char"
  done
  printf '%s' "$buf"
}

pause() {
  printf '\n  Press Enter to continue...'
  read -r -s
  printf '\n'
}

# ─── 16 colors ──────────────────────────────────────────────────────────────

colors16() {
  for bold in 0 1; do
    for i in $(seq 30 37); do
      for j in $(seq 40 47); do
        printf '\x1b[%s;%s;%sm %s;%s;%s |\x1b[0m' "$bold" "$i" "$j" "$bold" "$i" "$j"
      done
      printf '\n'
    done
    printf '\n'
  done

  for bold in 0 1; do
    for i in $(seq 90 97); do
      for j in $(seq 100 107); do
        printf '\x1b[%s;%s;%sm %s;%s;%s |\x1b[0m' "$bold" "$i" "$j" "$bold" "$i" "$j"
      done
      printf '\n'
    done
    printf '\n'
  done
}

# ─── 256 colors ─────────────────────────────────────────────────────────────

color1() {
  local c=$1 n=${2:-0}
  printf '\x1b[%s;38;5;%sm%4s\x1b[0m' "$n" "$c" "$c"
}

color1_sep() {
  local c=$1
  if (( (c - 15) % 18 == 0 )); then
    printf '\n'
  fi
}

color2() {
  local c=$1
  printf '\x1b[48;5;%sm  \x1b[0m' "$c"
}

color2_sep() {
  local c=$1
  if (( (c - 15) % 36 == 0 )); then
    printf '\n'
  elif (( (c - 15) % 6 == 0 )); then
    printf ' '
  fi
}

colors256() {
  local color_func=$1
  local sep_func=$2
  local n=${3:-}

  for i in $(seq 0 7); do
    $color_func "$i" $n
  done
  printf '\n'
  for i in $(seq 8 15); do
    $color_func "$i" $n
  done
  printf '\n\n'

  for i in $(seq 16 231); do
    $color_func "$i" $n
    $sep_func "$i"
  done
  printf '\n'

  for i in $(seq 232 255); do
    $color_func "$i" $n
  done
  printf '\n\n'
}

# ─── truecolor gradient ────────────────────────────────────────────────────

colors_gradient() {
  local s='/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/'
  for col in $(seq 0 76); do
    local r=$(( 255 - col * 255 / 76 ))
    local g=$(( col * 510 / 76 ))
    local b=$(( col * 255 / 76 ))
    if (( g > 255 )); then
      g=$(( 510 - g ))
    fi
    printf '\x1b[48;2;%s;%s;%sm\x1b[38;2;%s;%s;%sm%s\x1b[0m' \
      "$r" "$g" "$b" "$(( 255 - r ))" "$(( 255 - g ))" "$(( 255 - b ))" "${s:$col:1}"
  done
  printf '\n'
}

# ─── other SGR attributes ──────────────────────────────────────────────────

other_attributes() {
  for i in $(seq 0 9); do
    printf ' \x1b[%smSGR %2s\x1b[m ' "$i" "$i"
  done
  printf ' \x1b[53mSGR 53\x1b[m '  # overline
  printf '\n\n'
  # https://askubuntu.com/a/985386/235132
  for i in $(seq 1 5); do
    printf ' \x1b[4:%smSGR 4:%s\x1b[m ' "$i" "$i"
  done
  printf ' \x1b[21mSGR 21\x1b[m '

  printf ' \x1b[4:3m\x1b[58;2;135;0;255mtruecolor underline\x1b[59m\x1b[4:0m '
  printf ' \x1b]8;;https://askubuntu.com/a/985386/235132\x1b\\hyperlink\x1b]8;;\x1b\\\n'
}

# ─── SGR reset verification ────────────────────────────────────────────────

sgr_reset_test() {
  printf '  Before reset: \x1b[1;3;4;7;31;42m BOLD+ITALIC+UNDERLINE+REVERSE+RED+GREENBG \x1b[0m\n'
  printf '  After  SGR 0: This text should be completely normal (no residual styling).\n\n'

  printf '  Selective resets:\n'
  printf '    \x1b[1;4;31mBold+Underline+Red\x1b[22m -> remove bold\x1b[0m  (expect: underline+red only)\n'
  printf '    \x1b[1;4;31mBold+Underline+Red\x1b[24m -> remove uline\x1b[0m  (expect: bold+red only)\n'
  printf '    \x1b[1;4;31mBold+Underline+Red\x1b[39m -> remove color\x1b[0m  (expect: bold+underline, default fg)\n'
  printf '    \x1b[1;4;31;42mAll on\x1b[49m -> remove bg\x1b[0m  (expect: bold+underline+red, default bg)\n'
}

# ─── Unicode & wide characters ─────────────────────────────────────────────

unicode_test() {
  printf '  ASCII:        Hello, World!\n'
  printf '  Latin ext:    cafe\xcc\x81 \xc3\xa9\xc3\xa8\xc3\xaa\xc3\xab \xc3\xbc\xc3\xb6\xc3\xa4 \xc3\xb1 \xc3\xa7\n'
  printf '  Combining:    e\xcc\x81 o\xcc\x88 n\xcc\x83 a\xcc\x8a u\xcc\x88\xcc\x84  (e+acute, o+diaeresis, n+tilde, a+ring, u+diaeresis+macron)\n'
  printf '  Greek:        \xce\xb1\xce\xb2\xce\xb3\xce\xb4\xce\xb5 \xce\xa3\xce\xa9\xce\xa0\n'
  printf '  Cyrillic:     \xd0\x97\xd0\xb4\xd1\x80\xd0\xb0\xd0\xb2\xd1\x81\xd1\x82\xd0\xb2\xd1\x83\xd0\xb9\xd1\x82\xd0\xb5\n'
  printf '  CJK:          \xe4\xb8\xad\xe6\x96\x87 \xe6\x97\xa5\xe6\x9c\xac\xe8\xaa\x9e \xed\x95\x9c\xea\xb5\xad\xec\x96\xb4\n'
  printf '  Japanese:     \xe3\x81\xb2\xe3\x82\x89\xe3\x81\x8c\xe3\x81\xaa \xe3\x82\xab\xe3\x82\xbf\xe3\x82\xab\xe3\x83\x8a\n'
  printf '  Emoji:        \xf0\x9f\x98\x80 \xf0\x9f\x98\x82 \xf0\x9f\xa4\x94 \xf0\x9f\x91\x8d \xf0\x9f\x8e\x89 \xf0\x9f\x94\xa5 \xf0\x9f\x9a\x80 \xe2\x9c\x85 \xe2\x9d\x8c \xf0\x9f\x92\xbb\n'
  printf '  Emoji skin:   \xf0\x9f\x91\x8b\xf0\x9f\x8f\xbb \xf0\x9f\x91\x8b\xf0\x9f\x8f\xbc \xf0\x9f\x91\x8b\xf0\x9f\x8f\xbd \xf0\x9f\x91\x8b\xf0\x9f\x8f\xbe \xf0\x9f\x91\x8b\xf0\x9f\x8f\xbf\n'
  printf '  Emoji ZWJ:    \xf0\x9f\x91\xa8\xe2\x80\x8d\xf0\x9f\x91\xa9\xe2\x80\x8d\xf0\x9f\x91\xa7\xe2\x80\x8d\xf0\x9f\x91\xa6 (family)  \xf0\x9f\x8f\xb3\xef\xb8\x8f\xe2\x80\x8d\xf0\x9f\x8c\x88 (rainbow flag)\n'
  printf '  Flags:        \xf0\x9f\x87\xba\xf0\x9f\x87\xb8 \xf0\x9f\x87\xac\xf0\x9f\x87\xa7 \xf0\x9f\x87\xaf\xf0\x9f\x87\xb5 \xf0\x9f\x87\xa9\xf0\x9f\x87\xaa \xf0\x9f\x87\xab\xf0\x9f\x87\xb7 \xf0\x9f\x87\xa7\xf0\x9f\x87\xb7\n'
  printf '  Math symbols: \xe2\x88\x80 \xe2\x88\x83 \xe2\x88\x85 \xe2\x88\x88 \xe2\x88\x89 \xe2\x88\x8f \xe2\x88\x91 \xe2\x88\x9e \xe2\x89\x88 \xe2\x89\xa0 \xe2\x89\xa4 \xe2\x89\xa5\n'
  printf '  Arrows:       \xe2\x86\x90 \xe2\x86\x91 \xe2\x86\x92 \xe2\x86\x93 \xe2\x86\x94 \xe2\x86\x95 \xe2\x87\x90 \xe2\x87\x92 \xe2\x9f\xb5 \xe2\x9f\xb6\n'
  printf '  Braille:      \xe2\xa0\x81\xe2\xa0\x83\xe2\xa0\x89\xe2\xa0\x99\xe2\xa0\x91\xe2\xa0\x8b\xe2\xa0\x93\xe2\xa0\x9d\xe2\xa0\x9e\xe2\xa0\x9c\n'
  printf '  Alignment:    |%s|%s|%s| (each cell should be same width)\n' \
    "$(printf '\xe4\xb8\xad')" "$(printf '\xef\xbc\xa1')" "$(printf '\xef\xbc\xa2')"
}

# ─── alternate screen buffer ───────────────────────────────────────────────

alternate_screen_test() {
  printf '  This test will briefly switch to the alternate screen buffer.\n'
  pause

  # Switch to alternate screen
  printf '\x1b[?1049h'
  printf '\x1b[2J\x1b[H'  # clear and home
  printf '\n'
  printf '  ╔══════════════════════════════════════════╗\n'
  printf '  ║   You are now in the ALTERNATE SCREEN    ║\n'
  printf '  ║                                          ║\n'
  printf '  ║   If you can see this, alternate screen  ║\n'
  printf '  ║   buffer (CSI ?1049h) is supported.      ║\n'
  printf '  ║                                          ║\n'
  printf '  ║   Press Enter to return...               ║\n'
  printf '  ╚══════════════════════════════════════════╝\n'
  read -r -s

  # Switch back
  printf '\x1b[?1049l'
  printf '  Returned from alternate screen. If you see previous output, it works.\n'
}

# ─── mouse reporting ───────────────────────────────────────────────────────

mouse_reporting_test() {
  printf '  Mouse reporting modes (will be enabled then quickly disabled):\n\n'

  printf '  Testing SGR mouse mode (CSI ?1006h + CSI ?1000h)...\n'
  printf '  Click anywhere in the terminal within 3 seconds:\n'

  # Enable mouse tracking (X11 normal + SGR encoding)
  printf '\x1b[?1000h\x1b[?1006h' > /dev/tty

  local mouse_response
  mouse_response=$(read_response 3 < /dev/tty 2>/dev/null) || true

  # Disable mouse tracking
  printf '\x1b[?1006l\x1b[?1000l' > /dev/tty

  if [[ -n "$mouse_response" ]]; then
    printf '  Mouse event received: %s\n' "$(printf '%s' "$mouse_response" | cat -v)"
  else
    printf '  No mouse event captured (timeout or unsupported).\n'
  fi

  printf '\n  Mouse modes available:\n'
  printf '    CSI ?1000h  - Normal tracking (button press)\n'
  printf '    CSI ?1002h  - Button-event tracking (press + drag)\n'
  printf '    CSI ?1003h  - Any-event tracking (all motion)\n'
  printf '    CSI ?1006h  - SGR extended encoding (modern)\n'
  printf '    CSI ?1015h  - RXVT-unicode encoding\n'
}

# ─── sixel / kitty image protocol ──────────────────────────────────────────

image_protocol_test() {
  printf '  Sixel graphics test:\n'
  printf '  Drawing a 60x36 color bar pattern via Sixel...\n\n'

  # Sixel image: 60 pixels wide, 36 pixels tall (6 sixel rows of 6 pixels each)
  # 7 color bars: red, orange, yellow, green, cyan, blue, magenta
  # Each bar is ~8-9 pixels wide, filling 60 total
  printf '    '
  printf '\x1bPq'
  # Raster attributes: aspect 1:1, 60 wide, 36 tall
  printf '"1;1;60;36'
  # Define colors (HSL: hue;saturation;lightness)
  printf '#0;2;100;0;0'      # red
  printf '#1;2;100;50;0'     # orange
  printf '#2;2;100;100;0'    # yellow
  printf '#3;2;0;100;0'      # green
  printf '#4;2;0;100;100'    # cyan
  printf '#5;2;0;0;100'      # blue
  printf '#6;2;100;0;100'    # magenta

  # Sixel char '~' = 0x7E = all 6 bits set (0b111111) = solid 6-pixel column
  # Use !N~ for run-length encoding: repeat '~' N times
  # Each color bar is 8-9 pixels wide. 7 bars: 9+9+9+8+9+8+8 = 60
  # Draw 6 sixel rows (6 rows x 6 pixels = 36 pixels tall)
  local row
  for row in $(seq 1 6); do
    printf '#0!9~'
    printf '#1!9~'
    printf '#2!9~'
    printf '#3!8~'
    printf '#4!9~'
    printf '#5!8~'
    printf '#6!8~'
    # '-' moves to next sixel row (next 6 pixel lines)
    if (( row < 6 )); then
      printf '-'
    fi
  done
  printf '\x1b\\\n\n'

  printf '  If your terminal supports Sixel, you should see colored vertical\n'
  printf '  bars above (red, orange, yellow, green, cyan, blue, magenta).\n\n'

  printf '  Kitty graphics protocol test:\n'
  printf '  Transmitting a 16x8 RGBA image via Kitty protocol...\n\n'

  # Build a 16x8 RGBA image: rainbow gradient across columns, 8 rows
  # Each pixel = 4 bytes (RGBA). 16 cols x 8 rows = 512 bytes.
  local pixel_data=""
  local r g b
  for row in $(seq 0 7); do
    for col in $(seq 0 15); do
      # Hue mapped across 16 columns (0..360 degrees)
      local hue=$(( col * 360 / 16 ))
      # Simple HSV to RGB (full saturation, full value)
      local sector=$(( hue / 60 ))
      local frac=$(( (hue % 60) * 255 / 60 ))
      case $sector in
        0) r=255; g=$frac;          b=0 ;;
        1) r=$(( 255 - frac ));     g=255; b=0 ;;
        2) r=0;   g=255;            b=$frac ;;
        3) r=0;   g=$(( 255 - frac )); b=255 ;;
        4) r=$frac; g=0;            b=255 ;;
        *) r=255; g=0;              b=$(( 255 - frac )) ;;
      esac
      # Dim lower rows to create a gradient effect
      local bright=$(( 255 - row * 28 ))
      r=$(( r * bright / 255 ))
      g=$(( g * bright / 255 ))
      b=$(( b * bright / 255 ))
      pixel_data+=$(printf '\\x%02x\\x%02x\\x%02x\\xff' "$r" "$g" "$b")
    done
  done

  local rgba_data
  rgba_data=$(printf "$pixel_data" | base64 -w0 2>/dev/null || printf "$pixel_data" | base64 2>/dev/null)

  printf '    '
  # Kitty graphics: a=T (transmit+display), f=32 (raw RGBA), s=width, v=height
  printf '\x1b_Ga=T,f=32,s=16,v=8;%s\x1b\\' "$rgba_data"
  printf '\n\n'
  printf '  If your terminal supports the Kitty graphics protocol,\n'
  printf '  you should see a rainbow gradient block above (16x8 pixels,\n'
  printf '  fading from bright at top to dim at bottom).\n'
}

# ─── main ───────────────────────────────────────────────────────────────────

main() {
  section "Basic 16 Colors (foreground & background)"
  colors16

  section "256 Colors"
  colors256 color1 color1_sep

  section "256 Colors, Bold"
  colors256 color1 color1_sep 1

  section "256 Colors, Dim"
  colors256 color1 color1_sep 2

  section "256 Colors, Bold+Dim"
  colors256 color1 color1_sep '1;2'

  section "256 Colors, Solid Background"
  colors256 color2 color2_sep

  section "Truecolor Gradient"
  colors_gradient

  section "SGR Attributes"
  other_attributes

  section "SGR Reset Verification"
  sgr_reset_test

  section "Unicode & Wide Characters"
  unicode_test

  section "Alternate Screen Buffer (CSI ?1049h)"
  alternate_screen_test

  section "Mouse Reporting (SGR Mode)"
  mouse_reporting_test

  section "Sixel & Kitty Image Protocol"
  image_protocol_test

  printf '\n\x1b[1;32mAll tests complete.\x1b[0m\n\n'
}

main "$@"
