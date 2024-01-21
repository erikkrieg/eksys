## For debugging:
# echo "realpath: $1"
# echo "word: $2"
# echo "words: $3"
# echo "group: $4"

case "$1" in
  -*) exit 0 ;;
esac

if [ -e "$1" ]; then
  case "$(FILE -L --mime-type "$1")" in
    *text*)
      BAT --color always --plain "$1"
      ;;
    *image* | *pdf)
      CATIMG -w 100 -r 2 "$1"
      ;;
    *directory*)
      EZA --icons -1 --color=always "$1"
      ;;
    *)
      echo "unknown file format"
      ;;
  esac
elif GIT rev-parse -q --verify "$1"; then
  export DELTA_FEATURES=+preview
  GIT show --color=always "$1" | DELTA
elif man -w "$2-$1" >/dev/null 2>&1; then
  BATMAN "$2-$1"
elif man -w "$1" >/dev/null 2>&1; then
  # This isn't perfect. Many subcommands can happen to match other programs
  # and therefore show the wrong manual.
  BATMAN "$1"
fi
