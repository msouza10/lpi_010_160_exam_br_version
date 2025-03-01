#!/bin/bash
#
# **LPI practice exam**
#
# | Author: msouza10
# | Created: Fri 28 Feb 2025 22:55:13 BRT
# | Last modified: Fri 28 Feb 2025 22:55:22 BRT
# | Description: This file contains Bash script for selection language
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
source <(curl -Ls "https://raw.githubusercontent.com/Noam-Alum/utils.sh/main/utils.sh")

xecho "$LPI_BANNER"

LANGUAGE_CODE=$(echo $LANG | cut -d'.' -f1 | cut -d'_' -f1)

if [[ "$LANGUAGE_CODE" == "pt" ]]; then
  MSG_TITLE="Escolha a fonte das questões do exame LPI:"
  MSG_OPTION_1="1 - Inglês"
  MSG_OPTION_2="2 - Português"
  MSG_PROMPT="Digite o número correspondente (1 ou 2): "
else
  MSG_TITLE="Choose the source of the LPI exam questions:"
  MSG_OPTION_1="1 - English"
  MSG_OPTION_2="2 - Portuguese"
  MSG_PROMPT="Enter the corresponding number (1 or 2): "
fi

echo "$MSG_TITLE"
echo "$MSG_OPTION_1"
echo "$MSG_OPTION_2"
read -p "$MSG_PROMPT" choose

if [[ "$choose" == "2" ]]; then
  LPI_PATH=formats/br_lang.sh
else
  LPI_PATH=formats/en_lang.sh
fi

bash $LPI_PATH
