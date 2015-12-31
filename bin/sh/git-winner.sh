#!/bin/sh

usage() {
  echo "git-winner by Garry Dolley (http://scie.nti.st)"
  echo ""
  echo "Usage: $0 [date] [--detail]"
  echo ""
  echo "  --detail shows a shortlog of commits in the results"
  exit
}

case $1 in
  -h) usage;;
  --help) usage;;
esac

if [ -n "$1" ]; then
  DATE=$1
else
  DATE=$(date +%m-%d-%Y) # Today
fi

if [ "$2" = "--detail" ]; then
  DETAIL=y
fi

PLAYERS=$(git shortlog --all --after="$DATE 00:00:00" | grep '^\w' | sed 's/\(.*\) ([0-9]*):/\1/')

HIGHEST_COMMIT_COUNT=0
HIGHEST_COMMIT_LINES=0

echo "Activity after $DATE"
echo "" 

if [ -z "$PLAYERS" ]; then
  echo "No players!"
  echo ""
  echo "Appears there have been no commits after $DATE.  Try an earlier date."
  exit
fi

IFS='
'

for player in $PLAYERS; do
  COMMIT_COUNT=$(git shortlog --all --after="$DATE 00:00:00" --author="$player" -w | grep ^"$player (" | sed "s/$player (\(.*\)):/\1/")
  COMMIT_LINES=$(git log      --all --after="$DATE 00:00:00" --author="$player" --pretty=format: --stat --diff-filter=M -w | grep '[0-9]* files changed, [0-9]* insertions.*, [0-9]* deletions' | awk '{ sum += $4 + $6} END { print sum }')

  if [ -z "$COMMIT_COUNT" ]; then
    COMMIT_COUNT=0
  fi

  if [ -z "$COMMIT_LINES" ]; then
    COMMIT_LINES=0
  fi

  if [ "$COMMIT_COUNT" -gt "$HIGHEST_COMMIT_COUNT" ]; then
    HIGHEST_COMMIT_COUNT=$COMMIT_COUNT
    HIGHEST_COMMIT_COUNT_PLAYER=$player
  fi

  if [ "$COMMIT_LINES" -gt "$HIGHEST_COMMIT_LINES" ]; then
    HIGHEST_COMMIT_LINES=$COMMIT_LINES
    HIGHEST_COMMIT_LINES_PLAYER=$player
  fi

  echo "Results for $player:"
  echo "  # of commits        : $COMMIT_COUNT"
  echo "  # of lines committed: $COMMIT_LINES"

  if [ -n "$DETAIL" ]; then
    echo ""
    echo "  Commit summary"
    echo ""
    git shortlog --all --after="$DATE 00:00:00" --author="$player" -w | grep -v ^"$player"
  fi
done

if [ "$HIGHEST_COMMIT_COUNT" -gt 0 ]; then
  echo ""
  echo "$HIGHEST_COMMIT_COUNT_PLAYER wins in commit count with $HIGHEST_COMMIT_COUNT commits!"
  echo "$HIGHEST_COMMIT_LINES_PLAYER wins in number of lines committed with $HIGHEST_COMMIT_LINES lines!"
  
  if [ "$HIGHEST_COMMIT_COUNT_PLAYER" = "$HIGHEST_COMMIT_LINES_PLAYER" ]; then
    FIRST_NAME=$(echo $HIGHEST_COMMIT_COUNT_PLAYER | awk '{ print $1 }')
  
    echo ""
    echo "$FIRST_NAME is the overall winner!!"
  fi
fi
