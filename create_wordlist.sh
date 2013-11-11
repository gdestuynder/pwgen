#!/bin/zsh
## This Source Code Form is subject to the terms of the Mozilla Public
## License, v. 2.0. If a copy of the MPL was not distributed with this
## file, You can obtain one at http://mozilla.org/MPL/2.0/.

#`aspell dump dicts' for a list of available languages.
LANG="en-wo_accents"
PWLEN=6
SEPS="- / , \ | _"
#180 billions (MD5 fastest commercial cluster @ 2012)
#Source: http://arstechnica.com/security/2012/12/25-gpu-cluster-cracks-every-standard-windows-password-in-6-hours/
MAXSPEED=180000000000
NSASPEED=$((MAXSPEED*100000))
MI6SPEED=$((MAXSPEED*1000000))

[[ $# -eq 1 ]] || {
	echo "USAGE: $0 <wordlist-output>"
	exit 127
}
OUTPUT="$1"

[[ -f ${OUTPUT} ]] && {
	echo "${OUTPUT} already exists, aborted."
	exit 127
}

which aspell > /dev/null || {
	echo "You must install aspell first"
	exit 127
}

nr=$(aspell -d ${LANG} dump master | tee ${OUTPUT} | wc -l | cut -d ' ' -f 1)

[[ $? -eq 0 ]] || {
	echo "aspell command failed. Missing dictionary for ${LANG}?"
	exit 127
}

echo "Wordlist has ${nr} words. "
plen=${PWLEN}.0
nrr=$((nr**plen))
echo "For ${PWLEN} words, you have ${nrr} combinations per passphrase available."
echo "At ${MAXSPEED} combinations per second it would take $((nrr/MAXSPEED/60/60/24/365)) years to crack a MD5 hash (best conditions)."
echo "At ${NSASPEED} combinations per second it would take $((nrr/NSASPEED/60/60/24/365)) years to crack a MD5 hash (best conditions - NSA speed is estimated @ 100000 faster than a single commercial systems)."
echo "At ${MI6SPEED} combinations per second it would take $((nrr/MI6SPEED/60/60/24/365)) years to crack a MD5 hash (best conditions - MI6 speed is estimated @ 1000000 (1M times, or 1M machines cluster) faster than a single commercial systems)."
echo "Best conditions: known amount of words, known dictionary, known word separator."
