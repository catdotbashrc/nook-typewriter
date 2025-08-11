#!/bin/sh
# Lightweight writing analysis tools for Nook
# Based on Matt Might's shell scripts
# Uses minimal RAM - runs in shell only

usage() {
  cat << EOF
Writing Check - Lightweight prose analysis

Usage: writing-check [OPTION] FILE

Options:
  -w, --weasel     Find weasel words (vague language)
  -p, --passive    Find passive voice
  -d, --dups       Find duplicate words
  -r, --repeat     Find repeated words in paragraphs
  -a, --all        Run all checks
  -h, --help       Show this help

Examples:
  writing-check -w draft.txt
  writing-check --all chapter1.md

EOF
}

# Weasel words that weaken writing
check_weasel() {
  echo "=== Checking for weasel words ==="
  egrep -n -i --color=always \
    '\<(many|various|very|fairly|several|extremely|exceedingly|quite|remarkably|few|surprisingly|mostly|largely|huge|tiny|excellent|interestingly|significantly|substantially|clearly|vast|relatively|completely|really|just|perhaps|maybe|somewhat|somehow|almost|basically|essentially|generally|kind of|sort of|often|probably|possibly|apparently|seemingly)\>' "$1" | head -20
  echo
}

# Passive voice detection
check_passive() {
  echo "=== Checking for passive voice ==="
  egrep -n -i --color=always \
    '\<(am|are|were|being|is|been|was|be)\>.*\<(told|asked|given|shown|taught|brought|sent|made|seen|heard|found|taken|chosen|kept|held|done|written|broken|spoken|stolen|frozen|gotten)\>' "$1" | head -20
  
  # Also check for -ed endings after be-verbs
  egrep -n -i --color=always \
    '\<(am|are|were|being|is|been|was|be)\>\s+(\w+ed|(\w+en))\>' "$1" | head -20
  echo
}

# Find duplicate adjacent words
check_dups() {
  echo "=== Checking for duplicate words ==="
  perl -ne 'while (/\b(\w+)\s+\1\b/gi) {print "$.: $1 $1\n"}' "$1" | head -20
  echo
}

# Find repeated words within paragraphs (overuse)
check_repeat() {
  echo "=== Checking for overused words in paragraphs ==="
  # Find words repeated 3+ times in a paragraph
  awk '
  /^$/ {
    # End of paragraph, check for repeated words
    for (word in count) {
      if (count[word] >= 3) {
        print "Line " NR ": \"" word "\" appears " count[word] " times"
      }
    }
    delete count
    next
  }
  {
    # Count words in current paragraph
    gsub(/[[:punct:]]/, "")
    for (i = 1; i <= NF; i++) {
      word = tolower($i)
      if (length(word) > 4) {  # Only check words longer than 4 chars
        count[word]++
      }
    }
  }
  ' "$1" | head -20
  echo
}

# Word count and basic statistics
show_stats() {
  echo "=== Document Statistics ==="
  words=$(wc -w < "$1")
  lines=$(wc -l < "$1")
  chars=$(wc -c < "$1")
  
  # Average words per sentence (rough estimate)
  sentences=$(grep -o '[.!?]' "$1" | wc -l)
  if [ "$sentences" -gt 0 ]; then
    avg_words=$((words / sentences))
  else
    avg_words=0
  fi
  
  echo "Words: $words"
  echo "Lines: $lines"
  echo "Characters: $chars"
  echo "Sentences (approx): $sentences"
  echo "Avg words/sentence: $avg_words"
  
  # Check if sentences are too long
  if [ "$avg_words" -gt 20 ]; then
    echo "⚠ Consider shorter sentences (avg > 20 words)"
  fi
  echo
}

# Main script
if [ $# -eq 0 ]; then
  usage
  exit 1
fi

FILE=""
CHECK_ALL=0
CHECK_WEASEL=0
CHECK_PASSIVE=0
CHECK_DUPS=0
CHECK_REPEAT=0

# Parse arguments
while [ $# -gt 0 ]; do
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    -w|--weasel)
      CHECK_WEASEL=1
      shift
      ;;
    -p|--passive)
      CHECK_PASSIVE=1
      shift
      ;;
    -d|--dups)
      CHECK_DUPS=1
      shift
      ;;
    -r|--repeat)
      CHECK_REPEAT=1
      shift
      ;;
    -a|--all)
      CHECK_ALL=1
      shift
      ;;
    *)
      FILE="$1"
      shift
      ;;
  esac
done

# Check if file exists
if [ ! -f "$FILE" ]; then
  echo "Error: File '$FILE' not found"
  exit 1
fi

echo "Analyzing: $FILE"
echo "=================="
echo

# Always show stats
show_stats "$FILE"

# Run requested checks
if [ $CHECK_ALL -eq 1 ]; then
  check_weasel "$FILE"
  check_passive "$FILE"
  check_dups "$FILE"
  check_repeat "$FILE"
else
  [ $CHECK_WEASEL -eq 1 ] && check_weasel "$FILE"
  [ $CHECK_PASSIVE -eq 1 ] && check_passive "$FILE"
  [ $CHECK_DUPS -eq 1 ] && check_dups "$FILE"
  [ $CHECK_REPEAT -eq 1 ] && check_repeat "$FILE"
fi

echo "Analysis complete. Happy writing!"