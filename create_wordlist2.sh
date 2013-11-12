#!/bin/bash
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Provides:
# Minimum amount of words in word list
# Filters out non-pure-alpha/ascii words
# Filters out specific words (like insults), in grep format: "fuck|word|blah"
# Requires words to be at least 4 char long
# Lowercases everything
#
# Version: 1.0
# Author: (c) 2013 Mozilla by kang@mozilla.com

LANG="en-wo_accents"
INSULTS_FILTER="fuck"
MIN_WL_LEN=90000

tmp=$(mktemp)

aspell -d ${LANG} dump master | \
	tr -cd '[:alpha:]\n' | \
	grep -v ${INSULTS_FILTER} | \
	grep -e '[^\ ]\{4,\}' | \
	tr '[:upper:]' '[:lower:]' | \
	sort -u > ${tmp}

nr=$(wc -l ${tmp} | cut -d ' ' -f 1)

[[ "$nr" -lt ${MIN_WL_LEN} ]] && {
	rm ${tmp}
	echo "Resulting wordlist is too small. Required: ${MIN_WL_LEN} words - got only: ${nr} words."
	exit 127
}
cat ${tmp}
rm ${tmp}
