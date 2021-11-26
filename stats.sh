#!/bin/bash

create_dir="$HOME/concordium-stats"
config_file="$create_dir/config.ini"
mem_alert=false
cpu_alert=false
disk_alert=false
block_diff_alert=false
peer_alert=false
#concordium_grpc_address=

#----------------------------------------------------------------------------------------------------#
# NOTE: PARAMETERS ARE CONTAINED IN CONFIG.INI                                                       #
#----------------------------------------------------------------------------------------------------#

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

#----------------------------------------------------------------------------------------------------#
# FILL PARAMETERS BELOW RETRIEVED FROM CONFIG.INI                                                    #
#----------------------------------------------------------------------------------------------------#

if get_config_value low_no_of_peers
then
  low_no_of_peers="$global_value"
fi

if get_config_value node_name
then
  node_name="$global_value"
fi

if get_config_value disk_max_percent
then
  disk_max_percent="$global_value"
fi

if get_config_value cpu_max_percent
then
  cpu_max_percent="$global_value"
fi

if get_config_value memory_max_percent
then
  memory_max_percent="$global_value"
fi

if get_config_value telegram_bot_token
then
  telegram_bot_token="$global_value"
fi

if get_config_value telegram_chat_id
then
  telegram_chat_id="$global_value"
fi

if get_config_value block_diff_threshold
then
  block_diff_threshold="$global_value"
fi

#----------------------------------------------------------------------------------------------------#
# CHECK RAM                                                                                          #
#----------------------------------------------------------------------------------------------------#

memory_used_percent="$(free | grep Mem | awk '{print $3/$2 * 100.0}' | awk -F '.' '{print $1}')"
memory_max_percent="$(echo $memory_max_percent | tr -d '%' )"


 if (( memory_used_percent >= memory_max_percent ))
  then
    mem_msg="❌ Memory is at $memory_used_percent percent used"
    mem_alert=true
else
mem_msg="Memory is fine at $memory_used_percent percent used percent used"
  fi

#----------------------------------------------------------------------------------------------------#
# CHECK DISK SPACE                                                                                   #
#----------------------------------------------------------------------------------------------------#
disk_used_percent="$(df -h | grep -w '/' | awk '{print $5}' | tr -d '%')"
disk_max_percent="$(echo $disk_max_percent | tr -d '%' )"

 if (( disk_used_percent >= disk_max_percent ))
  then
    disk_msg="❌ Disk space is at $disk_used_percent percent used"
    disk_alert=true
else
disk_msg="Disk space is at $disk_used_percent percent used which is OK"
  fi

echo "$disk_msg"


#----------------------------------------------------------------------------------------------------#
# CHECK CPU                                                                                          #
#----------------------------------------------------------------------------------------------------#

cpu_utilization=$((100 - $(vmstat 2 2 | tail -1 | awk '{print $15}' | sed 's/%//')))

if [[ $cpu_utilization -gt $cpu_max_percent ]]; then
cpu_msg="❌ CPU is at $cpu_utilization percent used"
echo "$cpu_msg"
cpu_alert=true
else
cpu_msg="CPU is $cpu_utilization which is ok"
fi

echo "$cpu_msg"


#----------------------------------------------------------------------------------------------------#
# PEER COUNT / INFO                                                                                  #
#----------------------------------------------------------------------------------------------------#

getData=$(curl -s -H "Content-Type: application/json" https://dashboard.mainnet.concordium.software/nodesSummary)
your_peer_count=$(echo $getData | jq '.[] | select(.nodeName == "'"${node_name}"'").peersCount')

if [[ $your_peer_count -lt $low_no_of_peers ]]; then
peer_msg="❌ LOW NUMBER OF PEERS: $your_peer_count (min permissible $low_no_of_peers)"
peer_alert=true
else
peer_msg="Peers is ok: $your_peer_count ok"
fi
echo "$peer_msg"


#----------------------------------------------------------------------------------------------------#
# CONCORDIUM BLOCK HEIGHT VS YOUR BLOCK HEIGHT                                                       #
#----------------------------------------------------------------------------------------------------#

block_height=$(curl -s -H "Content-Type: application/json" https://dashboard.mainnet.concordium.software/nodesSummary)
max_block_height=$(echo $block_height | jq '[ .[] | .bestBlockHeight ] | max')

my_block_height=$(curl -s -H "Content-Type: application/json" https://dashboard.mainnet.concordium.software/nodesSummary)
my_max_block_height=$(echo $my_block_height | jq '.[] | select(.nodeName == "'"${node_name}"'").bestBlockHeight')

echo "Concordium Block Height: $max_block_height - Your Block Height: $my_max_block_height"


block_diff=$(($max_block_height - $my_max_block_height))

if [[ $block_diff -gt $block_diff_threshold ]]; then
block_diff_msg="❌ Block difference of $block_diff as Concordium: $max_block_height and yours is: $my_max_block_height
"
block_diff_alert=true
else
block_diff_msg="Block Difference is within chosen limits"
fi
echo "$block_diff_msg"



alert=false

msg=""
if $mem_alert || $cpu_alert || $disk_alert || $block_diff_alert || $peer_alert
then
  alert=true
  if $mem_alert
  then
  msg="$msg
  $mem_msg"
  fi

  if $cpu_alert
  then
  msg="$msg
  $cpu_msg"
  fi

  if $disk_alert
  then
  msg="$msg
   $disk_msg"
  fi

  if $block_diff_alert
  then
  msg="$msg
  $block_diff_msg"
  fi

  if $peer_alert
  then
  msg="$msg
  $peer_msg"
  fi


fi

msg="ALERTS FOUND ON $node_name ($HOSTNAME)!
$msg"

#----------------------------------------------------------------------------------------------------#
# SEND ALERT NOTIFICATIONS TO TELEGRAM BOT (IF THERE'S SOMETHING TO SEND)                            #
#----------------------------------------------------------------------------------------------------#

  if $alert
  then

echo "Sending Telegram: $msg"

    curl -s -X POST https://api.telegram.org/bot$telegram_bot_token/sendMessage -d chat_id=$telegram_chat_id -d text="$msg" &>/dev/null
else
echo "No alerts needed"
  fi
