#!/bin/bash
#
readarray() {
  local __resultvar=$1
  declare -a __local_array
  let i=0
  while IFS=$'\n' read -r line_data; do
      __local_array[i]=${line_data}
      ((++i))
  done < $2
  if [[ "$__resultvar" ]]; then
    eval $__resultvar="'${__local_array[@]}'"
  else
    echo "${__local_array[@]}"
  fi
}

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1
fi

FILE=$1
TMPFILE="out.md"
cp $FILE $TMPFILE

echo "Starting conversion"
wc -c $TMPFILE

# delete text until first rule
echo "Tail"
sed -i -n '/Rule M0-1-1 (required, implementation, automated)/,$p' $TMPFILE
wc -c $TMPFILE

# delete text after last rule
echo "Head"
sed -i -n '/^7 References$/q;p' $TMPFILE
wc -c $TMPFILE

# delete PDF artifacts
echo "Remove page numbers"
sed -i '/^[0-9]\+ of [0-9]\+$/d' $TMPFILE
wc -c $TMPFILE
echo "Remove Footer"
sed -i '/AUTOSAR CONFIDENTIAL/d' $TMPFILE
sed -i '/Document ID 839/d' $TMPFILE
sed -i '/Guidelines for the use of the C++14 language$/d' $TMPFILE
sed -i '/^in critical and safety-related systems$/d' $TMPFILE
sed -i '/^AUTOSAR AP Release/d' $TMPFILE
wc -c $TMPFILE

# replace code line numbers
echo "Remove code line numbers"
sed -i '/^[0-9]\+$/d' $TMPFILE
wc -c $TMPFILE

# remove chapters
echo "Remove chapters"
sed -i '/^[0-9].[0-9]/d' $TMPFILE
wc -c $TMPFILE

# format rules
echo "Format rule paragraphs"
# join broken rule titles
sed -i '/^Rule [A,M][0-9]\+-[0-9]\+-[0-9]\+ (.*\//N;s/\n//' $TMPFILE
sed -i 's/^Rule [A,M][0-9]\+-[0-9]\+-[0-9]\+ (.*)$/\n> **&**\n>/g' $TMPFILE
wc -c $TMPFILE

# format sections
echo "Format sections"
sed -i 's/^Example$/## Example/g' $TMPFILE
sed -i 's/^Rationale$/## Rationale/g' $TMPFILE
sed -i 's/^Exception$/## Exception/g' $TMPFILE
sed -i 's/^See also$/## See also/g' $TMPFILE
sed -i 's/^Note:$/\n**Note:**/g' $TMPFILE

# code blocks
echo "Format start of code blocks"
sed -i 's/\/\/% \$Id:/```cpp\n\/\/% $Id:/g' $TMPFILE
sed -i 's/\/\/ \$Id:/```cpp\n\/\/ $Id:/g' $TMPFILE
wc -c $TMPFILE

echo "Format end of code blocks"
# Based on "see also" which is not a good heuristic
sed -i 's/^## See also/```\n\n&/g' $TMPFILE
wc -c $TMPFILE

# remove superfluous blank lines
echo "Remove superfluous blank lines"
sed -i '/^$/N;/^\n$/D' $TMPFILE
sed -i '1d' $TMPFILE
wc -c $TMPFILE

echo "Splitting rules"
csplit $TMPFILE '/^> \*\*Rule [A,M].*)\*\*$/' {*}

rm $TMPFILE

# create symmary
cp SUMMARY.tmp ../src/SUMMARY.md

readarray -d '' entries < <(printf '%s\0' xx* | sort -zV)
for f in "${entries[@]}"; do
    rule="$(head -1 "$f" | sed -n 's/.*\([A,M][0-9]\+-[0-9]\+-[0-9]\+\).*/\1/p')"
    if [ ! -z "$rule" ]; then
        mv "$f" "$rule.md"
        prettier -w "$rule.md"
        echo "  - [$rule](./$rule.md)" >> ../src/SUMMARY.md
    fi
done

echo "Cleaning up and moving files to src"
rm xx*
mv *.md ../src
