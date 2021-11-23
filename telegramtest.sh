#!/bin/bash
create_dir="$HOME/concordium-stats"
config_file="$create_dir/config.ini"

#----------------------------------------------------------------------------------------------------#
# GLOBAL VALUE IS USED AS A GLOBAL VARIABLE TO RETURN THE RESULT                                     #
#----------------------------------------------------------------------------------------------------#

function get_config_value(){
  global_value=$(grep -v '^#' "$config_file" | grep "^$1=" | awk -F '=' '{print $2}')
  if [ -z "$global_value" ]
  then
    return 1
  else
    return 0
  fi
}

if get_config_value telegram_bot_token
then
  telegram_bot_token="$global_value"
fi


if get_config_value telegram_chat_id
then
  telegram_chat_id="$global_value"
fi


curl -s -X POST https://api.telegram.org/bot$telegram_bot_token/sendMessage -d chat_id=$telegram_chat_id -d text="✅ Test Successful" &>/dev/null
echo "Check telegram"