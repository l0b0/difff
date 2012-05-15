#!/usr/bin/env bash
#
# NAME
#    difff.sh - Test difff script
#
# BUGS
#    https://github.com/l0b0/difff/issues
#
# COPYRIGHT AND LICENSE
#    Copyright (C) 2011-2012 Victor Engmark
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

declare -r directory=$(dirname $(readlink -f "$0"))
declare -r cmd="${directory}/difff.sh"
declare -r test_name=$'--$`!*@\a\b\E\f\r\t\v\\\'"\360\240\202\211 \n'

oneTimeSetUp() {
    test_dir="$__shunit_tmpDir"/"$test_name"
    file1="$test_dir/file1"
    file2="$test_dir/file2"
}

setUp() {
    mkdir -- "$test_dir"
    assertEquals 'Exit code' 0 $?
}

tearDown() {
    rm -r -- "$test_dir"
}

test_empty() {
    touch -- "$file1"
    touch -- "$file2"

    assertEquals "Field 1" x "$("$cmd" 1 "$file1" "$file2" && printf x)"
    assertEquals "Field 2-" x "$("$cmd" 2- "$file1" "$file2" && printf x)"
    assertEquals "Field 2-3" x "$("$cmd" 2-3 "$file1" "$file2" && printf x)"
    assertEquals "Field -3" x "$("$cmd" -3 "$file1" "$file2" && printf x)"
}

test_no_diff() {
    echo "abc ABC 123" > "$file1"
    echo "abc ABC 123" > "$file2"

    assertEquals "Field 1" x "$("$cmd" 1 "$file1" "$file2" && printf x)"
    assertEquals "Field 2-" x "$("$cmd" 2- "$file1" "$file2" && printf x)"
    assertEquals "Field 2-3" x "$("$cmd" 2-3 "$file1" "$file2" && printf x)"
    assertEquals "Field -3" x "$("$cmd" -3 "$file1" "$file2" && printf x)"
}

test_single_diff() {
    local -r common='abc ABC'
    local -r f1="$common 123"
    local -r f2="$common 456"
    echo "$f1" > "$file1"
    echo "$f2" > "$file2"

    assertEquals "Field 1" "1c1
< $f1
---
> $f2
"x "$("$cmd" 1 "$file1" "$file2" || printf x)"
    assertEquals "Field 2-" x "$("$cmd" 2- "$file1" "$file2" && printf x)"
    assertEquals "Field 2-3" x "$("$cmd" 2-3 "$file1" "$file2" && printf x)"
    assertEquals "Field -3" x "$("$cmd" -3 "$file1" "$file2" && printf x)"
}

test_longer_line() {
    local -r common="abc ABC"
    local -r f1="$common"
    local -r f2="$common 123"
    echo "$f1" > "$file1"
    echo "$f2" > "$file2"

    assertEquals "Field 1" "1c1
< $f1
---
> $f2
"x "$("$cmd" 1 "$file1" "$file2" || printf x)"
    assertEquals "Field 2-" x "$("$cmd" 2- "$file1" "$file2" && printf x)"
    assertEquals "Field 2-3" x "$("$cmd" 2-3 "$file1" "$file2" && printf x)"
    assertEquals "Field -3" x "$("$cmd" -3 "$file1" "$file2" && printf x)"
}

test_fields_diff() {
    local -ar c1=(a b c)
    local -ar f1c2=(1 2 3)
    local -ar f1c3=(E F G)
    local -ar f2c2=(M ${f1c2[1]} ${f1c2[2]})
    local -ar f2c3=(X Y ${f1c3[2]})
    for index in $(seq 0 $((${#c1[@]} - 1)))
    do
        echo "${c1[$index]} ${f1c2[$index]} ${f1c3[$index]}" >> "$file1"
        echo "${c1[$index]} ${f2c2[$index]} ${f2c3[$index]}" >> "$file2"
    done

    assertEquals "Field 1" "1,2c1,2
< a 1 E
< b 2 F
---
> a M X
> b 2 Y
"x "$("$cmd" 1 "$file1" "$file2" || printf x)"
    assertEquals "Field 2" "1c1
< b 2 F
---
> b 2 Y
"x "$("$cmd" 2 "$file1" "$file2" || printf x)"
    assertEquals "Field 3" x "$("$cmd" 3 "$file1" "$file2" && printf x)"
    assertEquals "Field 1-2" "1c1
< b 2 F
---
> b 2 Y
"x "$("$cmd" 1-2 "$file1" "$file2" || printf x)"
    assertEquals "Field 2-3" x "$("$cmd" 2-3 "$file1" "$file2" && printf x)"
}

# load and run shUnit2
test -n "${ZSH_VERSION:-}" && SHUNIT_PARENT=$0
. shunit2
