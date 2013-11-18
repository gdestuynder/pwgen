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
# Maximum passphrase len
#
# Version: 1.0
# Author: (c) 2013 Mozilla by kang@mozilla.com

LANG="en-wo_accents"
INSULTS_FILTER_FILE="bannedwords.txt"
MIN_WL_LEN=90000
PASSPHRASE_NR_WORDS=5
# Calculate max passphrase length depending on the amount of words
# Adjusted for separators
MAX_PASSPHRASE_LEN=70
MAX_WORD_LEN=$(((MAX_PASSPHRASE_LEN-PASSPHRASE_NR_WORDS+1)/PASSPHRASE_NR_WORDS))
MIN_WORD_LEN=4

tmp=$(mktemp)

# If the insult filter doesn't exists, create it to avoid errors
# This is simpler to understand that removing the option dynamically
# from the list of commands
[[ -f ${INSULTS_FILTER_FILE} ]] || touch ${INSULTS_FILTER_FILE}

aspell -d ${LANG} dump master | \
	tr -cd '[:alpha:]\n' | \
	grep -v -f ${INSULTS_FILTER_FILE} | \
	grep -we "[^\ ]\{${MIN_WORD_LEN},${MAX_WORD_LEN}\}" | \
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
