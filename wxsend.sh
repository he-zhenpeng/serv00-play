#!/bin/bash

text=$1

sendKey=${WXSENDEKEY}
title="msg_from_serv00-play"
URL="https://sctapi.ftqq.com/$sendKey.send?"
res=$(timeout 20s curl -s -X POST https://5742.push.ft07.com/send/sctp5742t93u1b5cumq82fnkmdleu7p.send? -d title=${title} -d desp="${text}")
  if [ $? == 124 ]; then
    echo "发送消息超时"
    exit 1
  fi

  err=$(echo "$res" | jq -r ".data.error")
  if [ "$err" == "SUCCESS" ]; then
    echo "微信推送成功"
  else
    echo "微信推送失败, error:$err"
  fi
