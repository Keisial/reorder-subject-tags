#!/bin/bash

set -e

REORDER_TAGS="$(dirname "$0")/reorder-tags"

test_case() {
	printf "Test %s... " "$1"
	OUTPUT="$(echo "$1" | $REORDER_TAGS ${3:-} foo bar)"
	if [ "$OUTPUT" = "$2" ]; then
	  echo Ok
	else
	  echo "Failed. Got «${OUTPUT}»"
	fi
}

test_case "Subject: hello world" "Subject: hello world"
test_case "Subject: [bar #12] hello world" "Subject: [foo #0] [bar #12] hello world"
test_case "Subject: [bar #12] [foo #50] hello world" "Subject: [foo #50] [bar #12] hello world"
test_case "Subject: [foo #5] [bar #2] hello world" "Subject: [foo #5] [bar #2] hello world"
test_case "Subject: [bar #12] [baz #30] [foo #50] hello world" "Subject: [foo #50] [baz #30] [bar #12] hello world"
test_case "Subject: [bar #0][bar #30] [foo #50] hello world" "Subject: [foo #50] [bar #30] hello world"
test_case "Subject: [foo #000][bar #30] [foo #50] hello world" "Subject: [foo #50] [bar #30] hello world"
test_case "Subject: [foo #000][bar #0][foo #50] hello world" "Subject: [foo #50] hello world"
test_case "Subject: hello
 [bar #2]
 world [foo #5]" "Subject: hello [foo #5] world [bar #2]"
test_case "From: John
 Smith <jsmith@example.com>
Subject: hello
 [bar #2]
 world [foo #5]" "From: John
 Smith <jsmith@example.com>
Subject: hello [foo #5] world [bar #2]"
test_case "Subject: [bar
 #2][foo #5] test" "Subject: [foo #5][bar #2] test"
test_case "Subject:
 =?UTF-8?Q?=5Bbar_=2312=5D_=5Bfoo_=2350=5D_rfc2047?=" "Subject: =?UTF-8?Q?=5Bfoo_=2350=5D_=5Bbar_=2312=5D_rfc2047?="
test_case "Subject: =?UTF-8?Q?=5Bbar #12=5D?= [foo #50]" "Subject: =?UTF-8?Q?[foo #50]?= =5Bbar #12=5D"  # Breaks if one tag is encoded but the other isn't
test_case $'From: joe@doe.com\nSubject: [bar #2][foo #5]' $'From: joe@doe.com\nSubject: [foo #5][bar #2]'
test_case $'From: joe@doe.com\nSubject: [bar #2][foo #5]' $'From: joe@doe.com\nSubject: [foo #5][bar #2]' "--filter /From:.*@doe\.com/"  # Filter if sent from Doe
test_case $'From: joe@doe.com\nSubject: [bar #2][foo #5]' $'From: joe@doe.com\nSubject: [bar #2][foo #5]' "--filter /From:.*@smith\.com/"  # But here we do not filter, as it doesn't come from Smith
test_case $'From: joe@doe.com\nSubject: [bar #2][foo #5]' $'From: joe@doe.com\nSubject: [foo #5][bar #2]' "--filter /From:.*@doe\.com/ --filter /From:.*joe/"  # Double filter
