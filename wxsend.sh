#!/bin/bash

text=$1

toWXMsg() {
  local msg=$1
  local title="*Serv00-play通知*"
  local host_icon="🖥️"
  local user_icon="👤"
  local time_icon="⏰"
  local notify_icon="📢"

  # 获取当前时间
  local current_time=$(date "+%Y-%m-%d %H:%M:%S")

  if [[ "$msg" != Host:* ]]; then
    local formatted_msg="${title}  \n\n"
    formatted_msg+="${time_icon} *时间：* ${current_time}  \n"
    formatted_msg+="${notify_icon} *通知内容：*    \n$msg  \n\n"
    echo -e "$formatted_msg"
    return
  fi

  local host=$(echo "$msg" | sed -n 's/.*Host:\([^,]*\).*/\1/p' | xargs)
  local user=$(echo "$msg" | sed -n 's/.*user:\([^,]*\).*/\1/p' | xargs)
  local notify_content=$(echo "$msg" | sed -E 's/.*user:[^,]*,//' | xargs)

  # 格式化消息内容，Markdown 换行使用两个空格 + 换行
  local formatted_msg="${title}  \n\n"
  formatted_msg+="${host_icon} *主机：* ${host}  \n"
  formatted_msg+="${user_icon} *用户：* ${user}  \n"
  formatted_msg+="${time_icon} *时间：* ${current_time}  \n\n"
  formatted_msg+="${notify_icon} *通知内容：* ${notify_content}  \n\n"

  echo -e "$formatted_msg|${host}|${user}" # 使用 -e 选项以确保换行符生效
}
sendKey=${WXSENDEKEY}

result=$(toWXMsg "$message_text")
formatted_msg=$(echo "$result" | awk -F'|' '{print $1}')
host=$(echo "$result" | awk -F'|' '{print $2}')
user=$(echo "$result" | awk -F'|' '{print $3}')

if [[ "$BUTTON_URL" == "null" ]]; then
  button_url="https://www.youtube.com/@frankiejun8965"
else
  button_url=${BUTTON_URL:-"https://www.youtube.com/@frankiejun8965"}
fi

URL="https://sctapi.ftqq.com/$sendKey.send?"

if [[ -n "$host" ]]; then
  button_url=$(replaceValue $button_url HOST $host)
fi
if [[ -n "$user" ]]; then
  button_url=$(replaceValue $button_url USER $user)
fi
if [[ -n "$PASS" ]]; then
  pass=$(toBase64 $PASS)
  button_url=$(replaceValue $button_url PASS $pass)
fi
encoded_url=$(urlencode "$button_url")
#echo "encoded_url: $encoded_url"
reply_markup='{
    "inline_keyboard": [
      [
        {"text": "点击查看", "url": "'"${encoded_url}"'"}
      ]
    ]
  }'
#echo "reply_markup: $reply_markup"

res=$(timeout 20s curl -s -X POST https://5742.push.ft07.com/send/sctp5742t93u1b5cumq82fnkmdleu7p.send? -d desp=${formatted_msg} -d reply_markup="${reply_markup}")
  if [ $? == 124 ]; then
    echo "发送消息超时"
    exit 1
  fi

  err=$(echo "$res" | jq -r ".message")
  
  if [ "$err" == "SUCCESS" ]; then
    echo "微信推送成功"
  else
    echo "微信推送失败, error:$err"
  fi
