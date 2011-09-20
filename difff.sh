#!/usr/bin/env bash
#
# NAME
#        difff.sh - Diff fields
#
# SYNOPSIS
#        difff FIELDS FILE1 FILE2
#
# DESCRIPTION
#        Finds identical FIELDS contents in FILE1 and FILE2, and diffs the rest
#        of the fields.
#
#        Can be used for example with two key/value configuration files with the
#        same format which have very different keys, but some overlap (maybe
#        they reference the same third-party tool). You could use a diff to find
#        discrepancies in the value, but the data you're looking for would be
#        completely swamped by uninteresting differences. The solution:
#        $ difff 1 foo.conf bar.conf
#
# EXAMPLES
#        difff 1 foo.txt bar.txt
#               Find same keys (field 1) with different values (fields 2-).
#
#        difff 2- foo.txt bar.txt
#               Find different keys (field 1) with the same value (fields 2-).
#
# BUGS
#        https://github.com/l0b0/difff/issues
#
# COPYRIGHT
#    Copyright (C) 2011 Victor Engmark
#
#    This program is free software: you can redistribute it and/or modify 
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
################################################################################

set -o errexit -o noclobber -o nounset -o pipefail

usage()
{
    # Print documentation until the first empty line
    # @param $1: Exit code (optional)
    while IFS= read -r -u 9
    do
        if [[ -z "$REPLY" ]]
        then
            exit ${1:-0}
        elif [[ "${REPLY:0:2}" == '#!' ]]
        then
            # Shebang line
            continue
        fi
        echo "${REPLY:2}" # Remove comment characters
    done 9< "$0"
}

if [[ $# -ne 3 ]]
then
    usage 1 >&2
fi

declare -r fields="${1:-1}"
field_separator="${IFS:0:1}"
declare -r field_separator="${field_separator:- }"
declare -r line_separator="${IFS: -1}"

similarities="$(comm -12 \
    <(cut -d "$field_separator" -f "$fields" "$2" | sort -u) \
    <(cut -d "$field_separator" -f "$fields" "$3" | sort -u))"

diff \
    <(while IFS= read -r -u 9 line
    do
        fields_text="$(cut -d "$field_separator" -f "$fields" <<<"$line")"
        while IFS= read -r -u 8 similarity
        do
            if [[ "$fields_text" = "$similarity" ]]
            then
                echo "$line"
            fi
        done 8<<<"$similarities"
    done 9< <(sort "$2")) \
    <(while IFS= read -r -u 9 line
    do
        fields_text="$(cut -d "$field_separator" -f "$fields" <<<"$line")"
        while IFS= read -r -u 8 similarity
        do
            if [[ "$fields_text" = "$similarity" ]]
            then
                echo "$line"
            fi
        done 8<<<"$similarities"
    done 9< <(sort "$3"))
