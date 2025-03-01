#!/bin/bash
#
# **LPI practice exam**
#
# | Author: msouza10
# | Created: Fri 28 Feb 2025 20:30:13 BRT
# | Last modified: Fri 28 Feb 2025 22:55:22 BRT
# | Description: This file contains Bash script that lets you practice for the LPIC practice exam in portuguese
#
# | Style
# | Fetch utils.sh
source <(curl -Ls "https://raw.githubusercontent.com/Noam-Alum/utils.sh/main/utils.sh")

# | Functions
function fail {
  test -z "$1" && local ERR_CODE="4" || ERR_CODE="$1"
  test -z "$2" && local ERR_MSG=":\n Erro desconhecido." || ERR_MSG="$2"
  xecho "$FAIL_BULLET <biw>$ERR_MSG</biw>\n" >&2

  # Exit even if a fork is calling fail
  if [ $BASH_SUBSHELL -gt 0 ]; then
    xecho "$FAIL_BULLET <biw>$ERR_MSG, O codigo de erro deve ser:</biw> <on_ib><biw>$ERR_CODE</biw></on_ib>\n" >&2
    pkill --signal 9 -f "$(basename $0)"
  fi

  exit "$ERR_CODE"
}

function get_random_function_id {
  test -z "$1" && fail 1 "número máximo não encontrado para $FUNCNAME !" || local MAX="$1"
  local MAX_TTL=100
  local RES=""

  while [ -z $RES ] && [ $MAX_TTL -lt 150 ]; do
    local GEN_RADOM_RESPONSE=$(gen_random int $(wc -c <<<"$MAX"))
    GEN_RADOM_RESPONSE=${GEN_RADOM_RESPONSE##0}
    if [[ $GEN_RADOM_RESPONSE -le $MAX && ! " $GEN_RADOM_RESPONSE " =~ " ${ASKED_QUESTIONS[@]} " ]]; then
      RES=$GEN_RADOM_RESPONSE
    fi
    let MAX_TTL--
  done

  echo "$RES"
}

# | Set environment
xecho "$LPI_BANNER"
xecho "<biw>{{ BR-scissors }} Configuração do ambiente ...</biw>\n"
## Check for jq
which jq &>/dev/null || fail 1 "jq não encontrado, instale e tente novamente."

## Fetch data
LPI_QUESTIONS_URL="https://raw.githubusercontent.com/msouza10/lpi_010_160_exam_br_version/refs/heads/main/lpi/lpi_questions_pt_br.json"
readonly LPI_QUESTIONS_URL

xecho "$INFO_BULLET <biw>Validando url.</biw>"
LPI_QUESTIONS_URL_RESPONSE_CODE="$(
  curl -o '/dev/null' \
    -I -s -w "%{http_code}\n" "$LPI_QUESTIONS_URL"
)"
if [ $LPI_QUESTIONS_URL_RESPONSE_CODE -eq 200 ]; then
  xecho "$INFO_BULLET <biw>Buscando perguntas da LPI</biw> <on_ib><biw> $LPI_QUESTIONS_URL </biw></on_ib><biw>.</biw>"
  readonly LPI_QUESTIONS_DATA="$(curl -Ls "$LPI_QUESTIONS_URL")"
else
  fail 1 "Não encontrado perguntas ($LPI_QUESTIONS_URL capturou $LPI_QUESTIONS_URL_RESPONSE_CODE codigo de resposta)."
fi
xecho "\n<biw>{{ BR-scissors }} Finalizado! {{ E-smile }}</biw>"

# Test
trap 'xecho "<on_ib><biw>CTRL+C</biw></on_ib> <biw>pressionado</biw>\n\n\n<biw>{{ BR-bear }}\n\nResultado:</biw> <on_ib><biw> ($LPI_CORRECT_ANSWERS/$(( $TOTAL_QUESTIONS + 1 ))) </biw></on_ib>\n";exit 1' SIGINT
LPI_CORRECT_ANSWERS=0
xecho "\n\n<biw>LPI Exame:\n{{ BR-bear }}</biw>\n"

TOTAL_QUESTIONS=$(($(jq -r .[-1].id <<<"$LPI_QUESTIONS_DATA") - 1))
readonly TOTAL_QUESTIONS

ASKED_QUESTIONS=()

while [ ${#ASKED_QUESTIONS[@]} -ne $TOTAL_QUESTIONS ]; do
  LPI_GOT_ALL_RIGHT=false
  QUESTION_INDEX=$(get_random_function_id $TOTAL_QUESTIONS)
  ASKED_QUESTIONS+=("$(jq -r .[$QUESTION_INDEX].id <<<"$LPI_QUESTIONS_DATA")")
  LPI_QUESTION="$(jq -r .[$QUESTION_INDEX].question <<<"$LPI_QUESTIONS_DATA")"

  TOTAL_LPI_ANSWERS="$(jq -r ".[$QUESTION_INDEX].answer | length" <<<"$LPI_QUESTIONS_DATA")"
  LPI_ANSWERS=()
  LPI_ANSWER_INDEX=0
  while [ $LPI_ANSWER_INDEX -lt $TOTAL_LPI_ANSWERS ]; do
    LPI_ANSWERS+=("$(jq -r ".[$QUESTION_INDEX].answer[$LPI_ANSWER_INDEX]" <<<"$LPI_QUESTIONS_DATA")")
    let LPI_ANSWER_INDEX++
  done

  TOTAL_QUESTION_OPTIONS=$(jq -r ".[$QUESTION_INDEX].options | length" <<<"$LPI_QUESTIONS_DATA")

  xecho "$INFO_BULLET <biw>$LPI_QUESTION</biw>\n"
  LPI_QUESTION_OPTIONS_INDEX=0
  LPI_QUESTIONS=()
  while [ $LPI_QUESTION_OPTIONS_INDEX -lt $TOTAL_QUESTION_OPTIONS ]; do
    LPI_OPTION="$(jq -r .[$QUESTION_INDEX].options[$LPI_QUESTION_OPTIONS_INDEX] <<<"$LPI_QUESTIONS_DATA")"
    xecho "   $(($LPI_QUESTION_OPTIONS_INDEX + 1))) <biw>$LPI_OPTION</biw>"
    LPI_QUESTIONS+=("$LPI_OPTION")
    let LPI_QUESTION_OPTIONS_INDEX++
  done

  LPI_USER_ANSWER_INDEX=0
  while [ $LPI_USER_ANSWER_INDEX -lt $TOTAL_LPI_ANSWERS ]; do
    user_input LPI_USER_ANSWER "int 1 $TOTAL_QUESTION_OPTIONS" "\n  $INFO_BULLET <biw>numero da resposta $(($LPI_USER_ANSWER_INDEX + 1)) (1 - $TOTAL_QUESTION_OPTIONS):</biw> "
    if [[ ! " ${LPI_ANSWERS[@]} " =~ " ${LPI_QUESTIONS[$(($LPI_USER_ANSWER - 1))]} " ]]; then
      xecho "  $FAIL_BULLET <biw>Errado! (a resposta correta é \"${LPI_ANSWERS[*]}\")</biw> <bir>{{ E-fail }}</bir>"
      LPI_GOT_ALL_RIGHT=false
      let LPI_USER_ANSWER_INDEX++
      unset LPI_USER_ANSWER
      break
    fi
    xecho "  $SUCCESS_BULLET <biw>Boa, esta correto</biw> <big>{{ E-success }}</big>"
    LPI_GOT_ALL_RIGHT=true
    let LPI_USER_ANSWER_INDEX++
    unset LPI_USER_ANSWER
  done
  echo -e "\n\n"

  if $LPI_GOT_ALL_RIGHT; then
    let LPI_CORRECT_ANSWERS++
  fi

  let QUESTION_INDEX++
  unset LPI_USER_ANSWER
done

xecho "\n\n<biw>{{ BR-bear }}\n\nResultado:</biw> <on_ib><biw> ($LPI_CORRECT_ANSWERS/$(($TOTAL_QUESTIONS + 1))</biw></on_ib>\n"
