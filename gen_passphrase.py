#!/usr/bin/env python
# encoding: utf-8

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Warning: will block on lack of randomness. You may want to run haveged.
# Requires os.SystemRandom for "true" random.

import random
import sys
import os
import re
from ordered_set import OrderedSet

ENTROPY_DEBUG=False
MIN_WORDS=50000
MIN_PASSPHRASE_LEN=26
PASSPHRASE_NR_WORDS=5
DELIMITERS=[' ','-',',','-','|','_']

try:
	rng = random.SystemRandom
except:
	print("True random generator required.")
	sys.exit(127)

def cleanup(w):
# Ensure words are super simple to type
# Note that this reduces entropy.
# That's OK tho as long as you check final
# word list entropy. I do.
	return re.findall('\w+', w)[0].lower()

def load_word_file(word_file):
	fd = os.path.expanduser(word_file)
	try:
		w = open(fd)
	except FileNotFoundError:
		print("%s does not exist. You need a wordlist." % (word_file))
		sys.exit(127)
# OrderedSet only accepts unique keys, ensures no duplicate words
	wrds = OrderedSet()
	for l in w:
		wrds.append(cleanup(l))
	wrds_len = len(wrds)
	if wrds_len < MIN_WORDS:
		print("Word list too small, need at least %u, got %u." % (MIN_WORDS, wrds_len))
		sys.exit(127)
	return wrds

def main():
	try:
		word_file = sys.argv[1]
	except IndexError:
		print("USAGE: %s <word_file>" % (sys.argv[0]))
		sys.exit(127)
	words = load_word_file(word_file)
	delim = rng().sample(DELIMITERS, 1)[0]
	pw = ""
	while len(pw) < MIN_PASSPHRASE_LEN:
		pw = delim.join((rng().sample(words, PASSPHRASE_NR_WORDS)))
	print(pw)
	del pw

	if ENTROPY_DEBUG:
# Calculates minimum entropy (attacker knows all config values and dictionary)
# Assumes bruteforce entropy is always higher (this is controlled by MIN_PASSPHRASE_LEN,
# considering we're only using ASCII [a-z], i.e. MIN_PASSPHRASE_LEN**26)
# Actual entropy may be higher if the attacker does not possess these informations.
		MI6_CHECKS=180000000000*1000000 #180 billions [2012 MD5 hash crack speed,
										#single multi GPU machine]
										#1 million of these machines.
		d_len=len(DELIMITERS)
		d_ent=d_len*PASSPHRASE_NR_WORDS-1
		w_len=len(words)
		w_ent=w_len**PASSPHRASE_NR_WORDS
		entropy=d_ent+w_ent
		print("Minimum entropy: There are %u possible combinations." % (entropy))
		print("At %u checks per second, it takes %u days to check all combinations." % (MI6_CHECKS, entropy/MI6_CHECKS/60/60/24))

if __name__ == "__main__":
	main()
