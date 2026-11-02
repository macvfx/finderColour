#!/bin/bash

# List or change Finder's modern colour tag for files and folders.
# Compatible with the Bash 3.2 shipped with macOS.

set -u

usage() {
    cat <<'EOF'
Usage:
  finder-labels.sh colours
  finder-labels.sh list [-r|--recursive] PATH...
  finder-labels.sh get PATH...
  finder-labels.sh set COLOUR PATH...
  finder-labels.sh clear PATH...

Colours (and modern Finder colour numbers):
  none=0  grey/gray=1  green=2  purple=3  blue=4
  yellow=5  red=6  orange=7

Examples:
  ./finder-labels.sh list "$HOME/Documents/Projects"
  ./finder-labels.sh list --recursive "$HOME/Documents/Projects"
  ./finder-labels.sh set green "Client Delivery"
  ./finder-labels.sh clear "Client Delivery"

"list" shows the contents of each directory (one level unless --recursive).
"get" shows only the paths passed to it.
EOF
}

fail() {
    printf 'finder-labels: %s\n' "$*" >&2
    exit 1
}

colour_index() {
    case $(printf '%s' "$1" | tr '[:upper:]' '[:lower:]') in
        none|clear|0) printf '0' ;;
        grey|gray|1)  printf '1' ;;
        green|2)      printf '2' ;;
        purple|3)     printf '3' ;;
        blue|4)       printf '4' ;;
        yellow|5)     printf '5' ;;
        red|6)        printf '6' ;;
        orange|7)     printf '7' ;;
        *) return 1 ;;
    esac
}

index_colour() {
    case "$1" in
        0) printf 'none' ;;
        1) printf 'grey' ;;
        2) printf 'green' ;;
        3) printf 'purple' ;;
        4) printf 'blue' ;;
        5) printf 'yellow' ;;
        6) printf 'red' ;;
        7) printf 'orange' ;;
        *) printf 'unknown' ;;
    esac
}

absolute_path() {
    local input=$1
    local parent base

    if [ -d "$input" ]; then
        (cd -P -- "$input" 2>/dev/null && pwd -P)
        return
    fi

    parent=$(dirname -- "$input") || return 1
    base=$(basename -- "$input") || return 1
    parent=$(cd -P -- "$parent" 2>/dev/null && pwd -P) || return 1
    printf '%s/%s\n' "$parent" "$base"
}

read_index() {
    osascript -l JavaScript - "$1" <<'JXA'
ObjC.import('Foundation')

function run(argv) {
    const url = $.NSURL.fileURLWithPath(argv[0])
    const error = Ref()
    const values = url.resourceValuesForKeysError(['NSURLLabelNumberKey'], error)

    if (!values) {
        throw new Error(ObjC.unwrap(error[0].localizedDescription))
    }

    const number = values.objectForKey('NSURLLabelNumberKey')
    return number ? String(ObjC.unwrap(number)) : '0'
}
JXA
}

show_path() {
    local path absolute index colour
    path=$1

    if [ ! -e "$path" ]; then
        printf 'ERROR\tmissing\t%s\n' "$path" >&2
        return 1
    fi

    absolute=$(absolute_path "$path") || {
        printf 'ERROR\tunresolved\t%s\n' "$path" >&2
        return 1
    }
    index=$(read_index "$absolute") || {
        printf 'ERROR\tFinder could not read\t%s\n' "$absolute" >&2
        return 1
    }
    colour=$(index_colour "$index")
    printf '%s\t%s\t%s\n' "$index" "$colour" "$absolute"
}

set_paths() {
    local index=$1
    shift

    [ "$#" -gt 0 ] || fail 'no files or folders supplied'

    osascript -l JavaScript - "$index" "$@" <<'JXA'
ObjC.import('Foundation')

function run(argv) {
    const colourNumber = Number(argv[0])
    const tagNames = [null, 'Gray', 'Green', 'Purple', 'Blue', 'Yellow', 'Red', 'Orange']
    const value = colourNumber === 0
        ? $([])
        : $([tagNames[colourNumber] + '\n' + colourNumber])
    let changedCount = 0

    for (let argumentNumber = 1; argumentNumber < argv.length; argumentNumber++) {
        const url = $.NSURL.fileURLWithPath(argv[argumentNumber])
        const error = Ref()
        const ok = url.setResourceValueForKeyError(value, $.NSURLTagNamesKey, error)

        if (!ok) {
            throw new Error(ObjC.unwrap(error[0].localizedDescription))
        }
        changedCount++
    }

    return changedCount
}
JXA
}

command=${1:-}
[ -n "$command" ] || {
    usage
    exit 2
}
shift

case "$command" in
    -h|--help|help)
        usage
        ;;

    colours|colour|colors|color)
        printf '%s\n' \
            '0  none' '1  grey' '2  green' '3  purple' \
            '4  blue' '5  yellow' '6  red' '7  orange'
        ;;

    get)
        [ "$#" -gt 0 ] || fail 'get requires at least one path'
        status=0
        for path in "$@"; do
            show_path "$path" || status=1
        done
        exit "$status"
        ;;

    list)
        recursive=0
        if [ "${1:-}" = '-r' ] || [ "${1:-}" = '--recursive' ]; then
            recursive=1
            shift
        fi
        [ "$#" -gt 0 ] || fail 'list requires at least one path'

        status=0
        for path in "$@"; do
            if [ -d "$path" ]; then
                if [ "$recursive" -eq 1 ]; then
                    while IFS= read -r -d '' child; do
                        show_path "$child" || status=1
                    done < <(find "$path" -mindepth 1 -print0)
                else
                    while IFS= read -r -d '' child; do
                        show_path "$child" || status=1
                    done < <(find "$path" -mindepth 1 -maxdepth 1 -print0)
                fi
            else
                show_path "$path" || status=1
            fi
        done
        exit "$status"
        ;;

    set)
        [ "$#" -ge 2 ] || fail 'set requires a colour and at least one path'
        colour=$1
        shift
        index=$(colour_index "$colour") || fail "unknown colour: $colour"

        absolute_paths=()
        for path in "$@"; do
            [ -e "$path" ] || fail "path does not exist: $path"
            absolute_paths+=("$(absolute_path "$path")")
        done
        count=$(set_paths "$index" "${absolute_paths[@]}") || exit 1
        printf 'Changed %s item(s) to %s (index %s).\n' \
            "$count" "$(index_colour "$index")" "$index"
        ;;

    clear)
        [ "$#" -gt 0 ] || fail 'clear requires at least one path'
        absolute_paths=()
        for path in "$@"; do
            [ -e "$path" ] || fail "path does not exist: $path"
            absolute_paths+=("$(absolute_path "$path")")
        done
        count=$(set_paths 0 "${absolute_paths[@]}") || exit 1
        printf 'Cleared the label from %s item(s).\n' "$count"
        ;;

    *)
        usage >&2
        fail "unknown command: $command"
        ;;
esac
