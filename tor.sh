#!/bin/bash

check_tor_connection() {
  local port=$1
  printf "\e[1;92m[*] Checking Tor connection on port:\e[0m\e[1;77m %s\e[0m..." "$port"
  local check=$(curl --socks5-hostname "localhost:$port" -s https://www.google.com > /dev/null; echo $?)
  if [[ $check -gt 0 ]]; then
    printf "\e[1;91mFAIL!\e[0m\n"
    return 1
  else
    printf "\e[1;92mOK!\e[0m\n"
    return 0
  fi
}

declare -a ports=("9051" "9052" "9053" "9054" "9055")
declare -i checkcount=0

if [[ ! -d multitor ]]; then
  mkdir multitor
  printf "SOCKSPort 9051\nDataDirectory /var/lib/tor1" > multitor/multitor1
  printf "SOCKSPort 9052\nDataDirectory /var/lib/tor2" > multitor/multitor2
  printf "SOCKSPort 9053\nDataDirectory /var/lib/tor3" > multitor/multitor3
  printf "SOCKSPort 9054\nDataDirectory /var/lib/tor4" > multitor/multitor4
  printf "SOCKSPort 9055\nDataDirectory /var/lib/tor5" > multitor/multitor5
fi

for port in "${ports[@]}"; do
  printf "\e[1;92m[*] Starting Tor on port:\e[0m\e[1;77m %s\e[0m\n" "$port"
  tor -f "multitor/multitor$port" > /dev/null &
  sleep 6

  if check_tor_connection "$port"; then
    let checkcount++
  fi
done

if [[ $checkcount -ne ${#ports[@]} ]]; then
  printf "\e[1;91mRequire all TOR connections running to continue. Exiting\e[0m\n"
  exit 1
fi

printf "\n"
printf "\e[1;77m[*] init__0\e[0m\n"
printf "\e[1;77m[*] Starting...\e[0m\n"
printf "\e[1;91m [*] run ./killtor to Stop\e[0m\n"
sleep 2
