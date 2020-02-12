#!/bin/bash

set -e

REORDER_TAGS="$(dirname "$0")/reorder-tags"

test_case() {
	printf "Test %s... " "$1"
	OUTPUT="$(echo "$1" | $REORDER_TAGS foo bar)"
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
