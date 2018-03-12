#!/bin/bash

[ -z $(which tput 2>/dev/null) ] && { printf "%s\n" "tput not found"; exit 1; }

GRN=$(tput setaf 2)
YLW=$(tput setaf 3)
RED=$(tput setaf 1)
CLR=$(tput sgr0)

ANSWERS=(
"`printf "${GRN}●${CLR} It is certain"`"
"`printf "${GRN}●${CLR} It is decidedly so"`"
"`printf "${GRN}●${CLR} Without a doubt"`"
"`printf "${GRN}●${CLR} Yes definitely"`"
"`printf "${GRN}●${CLR} You may rely on it"`"
"`printf "${GRN}●${CLR} As I see it yes"`"
"`printf "${GRN}●${CLR} Most likely"`"
"`printf "${GRN}●${CLR} Outlook good"`"
"`printf "${GRN}●${CLR} Yes"`"
"`printf "${GRN}●${CLR} Signs point to yes"`"
"`printf "${YLW}●${CLR} Reply hazy try again"`"
"`printf "${YLW}●${CLR} Ask again later"`"
"`printf "${YLW}●${CLR} Better not tell you now"`"
"`printf "${YLW}●${CLR} Cannot predict now"`"
"`printf "${YLW}●${CLR} Concentrate and ask again"`"
"`printf "${RED}●${CLR} Dont count on it"`"
"`printf "${RED}●${CLR} My reply is no"`"
"`printf "${RED}●${CLR} My sources say no"`"
"`printf "${RED}●${CLR} Outlook not so good"`"
"`printf "${RED}●${CLR} Very doubtful"`"
)

MOD=${#ANSWERS[*]}
INDEX=$(($RANDOM%$MOD))
W_CNT=$((${#ANSWERS[$INDEX]}-9))

printf $(tput clear)
tput cup $(($(tput lines)/2)) $((($(tput cols)/2)-($W_CNT/2)))
printf "${ANSWERS[$INDEX]}"
tput cup $(tput lines) 0
