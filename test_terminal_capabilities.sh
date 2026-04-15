#!/usr/bin/env bash

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

# --- main ---
printf 'basic 16 colors, foreground & background:\n\n'
colors16

printf '256 colors:\n\n'
colors256 color1 color1_sep

printf '256 colors, bold:\n\n'
colors256 color1 color1_sep 1

printf '256 colors, dim:\n\n'
colors256 color1 color1_sep 2

printf '256 colors, bold dim:\n\n'
colors256 color1 color1_sep '1;2'

printf '256 colors, solid background:\n\n'
colors256 color2 color2_sep

printf 'true colors gradient:\n\n'
colors_gradient

printf 'other attributes:\n\n'
other_attributes
