#!/bin/bash
# Dynamic MOTD for SquireOS - Shows different medieval writing wisdom daily

# Array of jester moods
declare -a JESTER_MOODS=(
"     .~\"~.~\"~.
    /  o   o  \\      
   |  >  ◡  <  |     
    \\  ___  /        
     |~|♦|~|"         

"     .~\"~.~\"~.
    /  ^   ^  \\      
   |  >  ‿  <  |     
    \\  ___  /        
     |~|♦|~|"

"     .~\"~.~\"~.
    /  -   -  \\      
   |  >  ~  <  |     
    \\  ___  /        
     |~|♦|~|"

"     .~\"~.~\"~.
    /  @   @  \\      
   |  > ___< |     
    \\  ~~~ /        
     |~|♦|~|"
)

# Array of daily wisdoms from literature on writing
declare -a WISDOMS=(
"\"An article that bristles with symbols... is devoid of real content and nothing but a Chinese pharmacy.\" - A wise Chinese philosopher"
"\"Do not force yourself to write when you have nothing to say.\" - An ancient scribe from the East"
"\"Literature must become a cog and screw of one single great mechanism.\" - A portly balding statesman"
"\"Down with non-partisan writers! Down with literary supermen!\" - A bearded revolutionary"
"\"Writers are engineers of human souls.\" - A mustachioed Georgian poet"
"\"The method borrowed from the Chinese pharmacy... is really the most crude, infantile and philistine of all.\" - A rural librarian"
"\"Read it over twice at least... and strike out non-essential words.\" - A meticulous editor from Hunan"
"\"We must learn to talk to the masses in the language which the masses understand.\" - A people's teacher"
"\"Pay close attention to all manner of things; observe more.\" - A mountain sage"
"\"Empty verbiage is like shooting at random without considering the audience.\" - A concerned pamphleteer"
"\"Literature cannot be a means of enriching individuals.\" - A collective of unnamed scribes"
"\"Investigate and study before writing.\" - A methodical researcher"
)

# Array of squire comments with revolutionary spirit
declare -a COMMENTS=(
"I've arranged your manuscripts without complicated headings, m'lord!"
"Today I avoided the Chinese pharmacy method entirely!"
"Your writing serves the common cause, not individual enrichment!"
"I've prepared your quill to engineer souls, as the mustachioed Georgian poet once advised!"
"No formalist methods here - only internal relations!"
"The scriptorium rejects literary supermen!"
"Your words are cogs in the great mechanism, m'lord!"
)

# Get day of year for consistent daily rotation
DOY=$(date +%j)

# Select items based on day
JESTER_INDEX=$((DOY % ${#JESTER_MOODS[@]}))
WISDOM_INDEX=$((DOY % ${#WISDOMS[@]}))
COMMENT_INDEX=$((DOY % ${#COMMENTS[@]}))

# Special date messages
SPECIAL_MSG=""
case "$(date +%m-%d)" in
    "01-01") SPECIAL_MSG="🎊 Happy New Year! A fresh tome begins!" ;;
    "04-23") SPECIAL_MSG="📜 'Tis Shakespeare's Birthday! \"To write or not to write...\"" ;;
    "06-23") SPECIAL_MSG="⌨️ Happy Typewriter Day! (But we prefer quills!)" ;;
    "11-01") SPECIAL_MSG="✍️ NaNoWriMo begins! 50,000 words await thy quill!" ;;
    "11-30") SPECIAL_MSG="🏆 NaNoWriMo ends! How fared thy quest?" ;;
esac

# Output MOTD
cat << EOF
═══════════════════════════════════════════════════════════════════════

                           HARK! A MESSAGE FROM YOUR SQUIRE

${JESTER_MOODS[$JESTER_INDEX]}
    d|     |b        ${COMMENTS[$COMMENT_INDEX]}

═══════════════════════════════════════════════════════════════════════

  📜 Today's Ancient Wisdom:
     ${WISDOMS[$WISDOM_INDEX]}

EOF

# Add special message if applicable
if [ -n "$SPECIAL_MSG" ]; then
    echo "  🎉 $SPECIAL_MSG"
    echo ""
fi

cat << 'EOF'
  💡 Quick Commands for Your Literary Quest:
  
  • scribe          - Begin a new manuscript
  • scroll          - Browse your written works  
  • chronicle       - View thy writing statistics
  • summon [name]   - Open an existing scroll
  • seal            - Save and export your work

═══════════════════════════════════════════════════════════════════════

EOF

# Add writing stats if available
if [ -f "$HOME/.squireos/stats" ]; then
    source "$HOME/.squireos/stats"
    echo "  📊 Thy Writing Progress:"
    echo "     Words today: ${WORDS_TODAY:-0} | Total words: ${WORDS_TOTAL:-0}"
    echo "     Current streak: ${STREAK_DAYS:-0} days"
    echo ""
    echo "═══════════════════════════════════════════════════════════════════════"
fi

echo "  System: SquireOS 1.0.0 (Parchment) | Kernel: QuillKernel 2.6.29"
echo "  \"By quill and candlelight, we persist!\""
echo ""
echo "═══════════════════════════════════════════════════════════════════════"
