#!/bin/bash
#
# **LPI practice exam**
#
# | Author: Noam Alum
# | Created: Thu 19 Dec 2024 12:36:22 IST
# | Last modified: Thu 19 Dec 2024 14:30:58 IST
# | Description: This file contains Bash script that lets you practice for the LPI practice exam.
#



# | Style
readonly LPI_BANNER="<bic>

    ██╗     ██████╗ ██╗    ███████╗██╗  ██╗ █████╗ ███╗   ███╗
    ██║     ██╔══██╗██║    ██╔════╝╚██╗██╔╝██╔══██╗████╗ ████║
    ██║     ██████╔╝██║    █████╗   ╚███╔╝ ███████║██╔████╔██║
    ██║     ██╔═══╝ ██║    ██╔══╝   ██╔██╗ ██╔══██║██║╚██╔╝██║
    ███████╗██║     ██║    ███████╗██╔╝ ██╗██║  ██║██║ ╚═╝ ██║
    ╚══════╝╚═╝     ╚═╝    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝

</bic>"
readonly SUCCESS_BULLET=" <big>{{ B-arrow }}</big>"
readonly FAIL_BULLET=" <bir>{{ B-arrow }}</bir>"
readonly INFO_BULLET=" <biw>{{ B-arrow }}</biw>"



# | Fetch utils.sh
source <(curl -Ls "https://raw.githubusercontent.com/Noam-Alum/utils.sh/main/utils-min.sh")

# | Functions
function fail {
	test -z "$1" && local ERR_CODE="4" || ERR_CODE="$1"
	test -z "$2" && local ERR_MSG=":\nNo error specified." || ERR_MSG="$2"
	xecho "$FAIL_BULLET <biw>$ERR_MSG</biw>\n" >&2

  # Exit even if a fork is calling fail
  if [ $BASH_SUBSHELL -gt 0 ]; then
    xecho "$FAIL_BULLET <biw>$ERR_MSG, Exit code should be:</biw> <on_ib><biw>$ERR_CODE</biw></on_ib>\n" >&2
    pkill --signal 9 -f "$(basename $0)"
  fi

  exit "$ERR_CODE"
}

function gen_random {
  test -z "$1" && local GR_OPT="all" || local GR_OPT="$1"
  test -z "$2" && local GR_LEN="12" || local GR_LEN="$2"

  case $GR_OPT in
    all)
      local CHARSET="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz,'\"!@#$%^&*()-_=+|[]{};:/?.>"
      ;;
    str)
      local CHARSET="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
      ;;
    int)
      local CHARSET="0123456789"
      ;;
    *)
      fail 3 ":\nError while using \"$FUNCNAME\" function, not a valid option ($GR_OPT), refer to \"https://docs.alum.sh/utils.sh/functions/gen_random.html\" for more information."
      ;;
  esac
  readonly CHARSET

  if [ -z "${GR_LEN//[0-9]}" ]; then
    local RES="$(tr -dc "$CHARSET" < /dev/urandom | head -c "$GR_LEN")"
  else
     fail 3 ":\nError while using \"$FUNCNAME\" function, length not an int ($GR_LEN), refer to \"https://docs.alum.sh/utils.sh/functions/gen_random.html\" for more information."
  fi

  if [ ! -z "$RES" ]; then
          echo "$RES"
          return 0
  else
          fail 4 ":\nUnknown error while using \"$FUNCNAME\" function, refer to \"https://docs.alum.sh/utils.sh/functions/gen_random.html\" for more information."
  fi
}

function get_random_function_id {
  test -z "$1" && fail 1 "No max number given for $FUNCNAME !" || local MAX="$1"
  local MAX_TTL=100
  local RES=""

  while [ -z $RES ] && [ $MAX_TTL -lt 150 ]
  do
    local GEN_RADOM_RESPONSE=$(gen_random int $(tr -cd '0-9' <<< "$MAX" | wc -c))
    if [[ $GEN_RADOM_RESPONSE -le $MAX && ! " $GEN_RADOM_RESPONSE " =~ " ${ASKED_QUESTIONS[@]} " ]]; then
      RES=$GEN_RADOM_RESPONSE
    fi
    let MAX_TTL--;
  done

  echo "${RES##0}"
}

# | Set environment
xecho "$LPI_BANNER"
xecho "<biw>{{ BR-scissors }} Setting environment ...</biw>\n"
## Check for jq
which jq &> /dev/null || fail 1 "jq not found, please install and try again."

## Fetch data
LPI_QUESTIONS_URL="https://alum.sh/files/lpi/lpi_questions.json"
readonly LPI_QUESTIONS_URL

xecho "$INFO_BULLET <biw>Validating url.</biw>"
LPI_QUESTIONS_URL_RESPONSE_CODE="$(curl -o '/dev/null'\
                                        -I -s\
                                        -w "%{http_code}\n"  "$LPI_QUESTIONS_URL"
                                  )"
if [ $LPI_QUESTIONS_URL_RESPONSE_CODE -eq 200 ]; then
  xecho "$INFO_BULLET <biw>Fetching LPI questions from</biw> <on_ib><biw> $LPI_QUESTIONS_URL </biw></on_ib><biw>.</biw>"
  readonly LPI_QUESTIONS_DATA="$(curl -Ls "$LPI_QUESTIONS_URL")"
else
  fail 1 "Can't fetch LPI questions ($LPI_QUESTIONS_URL got $LPI_QUESTIONS_URL_RESPONSE_CODE response code)."
fi
xecho "\n<biw>{{ BR-scissors }} Done! {{ E-smile }}</biw>"



# Test
trap 'xecho "<on_ib><biw>CTRL+C</biw></on_ib> <biw>pressed!</biw>\n\n\n<biw>{{ BR-bear }}\n\nResults:</biw> <on_ib><biw> ($LPI_CORRECT_ANSWERS/$TOTAL_QUESTIONS) </biw></on_ib>\n";exit 1' SIGINT
LPI_CORRECT_ANSWERS=0
xecho "\n\n<biw>LPI practice exam:\n{{ BR-bear }}</biw>\n"

TOTAL_QUESTIONS=$(( $(jq -r .[-1].id <<< "$LPI_QUESTIONS_DATA") - 1 ))
readonly TOTAL_QUESTIONS

ASKED_QUESTIONS=()

while [ ${#ASKED_QUESTIONS[@]} -ne $TOTAL_QUESTIONS ]
do
  QUESTION_INDEX=$(get_random_function_id $TOTAL_QUESTIONS)
  ASKED_QUESTIONS+=("$(jq -r .[$QUESTION_INDEX].id <<< "$LPI_QUESTIONS_DATA")")
  LPI_QUESTION="$(jq -r .[$QUESTION_INDEX].question <<< "$LPI_QUESTIONS_DATA")"

  TOTAL_LPI_ANSWERS="$(jq -r ".[$QUESTION_INDEX].answer | length" <<< "$LPI_QUESTIONS_DATA")"
  LPI_ANSWERS=()
  LPI_ANSWER_INDEX=0
  while [ $LPI_ANSWER_INDEX -lt $TOTAL_LPI_ANSWERS ]
  do
    LPI_ANSWERS+=("$(jq -r ".[$QUESTION_INDEX].answer[$LPI_ANSWER_INDEX]" <<< "$LPI_QUESTIONS_DATA")")
    let LPI_ANSWER_INDEX++;
  done

  TOTAL_QUESTION_OPTIONS=$(jq -r ".[$QUESTION_INDEX].options | length" <<< "$LPI_QUESTIONS_DATA")

  xecho "$INFO_BULLET <biw>$LPI_QUESTION</biw>\n"
  LPI_QUESTION_OPTIONS_INDEX=0
  LPI_QUESTIONS=()
  while [ $LPI_QUESTION_OPTIONS_INDEX -lt $TOTAL_QUESTION_OPTIONS ]
  do
    LPI_OPTION="$(jq -r .[$QUESTION_INDEX].options[$LPI_QUESTION_OPTIONS_INDEX] <<< "$LPI_QUESTIONS_DATA")"
    xecho "   $(( $LPI_QUESTION_OPTIONS_INDEX + 1 ))) <biw>$LPI_OPTION</biw>"
    LPI_QUESTIONS+=("$LPI_OPTION")
    let LPI_QUESTION_OPTIONS_INDEX++;
  done

  user_input LPI_USER_ANSWER "int 1 $TOTAL_QUESTION_OPTIONS" "\n  $INFO_BULLET <biw>Answer (1 - $TOTAL_QUESTION_OPTIONS):</biw> "

  if [[ " ${LPI_ANSWERS[@]} " =~ " ${LPI_QUESTIONS[$(( $LPI_USER_ANSWER - 1 ))]} " ]]; then
    xecho "  $SUCCESS_BULLET <biw>Nice you got that right</biw> <big>{{ E-success }}</big>\n\n"
    let LPI_CORRECT_ANSWERS++;
  else
    xecho "  $FAIL_BULLET <biw>Wrong! (current answer is \"${LPI_ANSWERS[@]}\")</biw> <bir>{{ E-fail }}</bir>\n\n"
  fi

  let QUESTION_INDEX++;
  unset LPI_USER_ANSWER
done

xecho "\n\n<biw>{{ BR-bear }}\n\nResults:</biw> <on_ib><biw> ($LPI_CORRECT_ANSWERS/$TOTAL_QUESTIONS) </biw></on_ib>\n"
