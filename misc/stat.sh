# ===== Colors =====
RESET='\033[0m'
BOLD='\033[1m'

WHITE='\033[37m'
GRAY='\033[90m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'
RED='\033[31m'

# ===== Helpers =====
label() {
    printf "${GRAY}%-14s${RESET}" "$1"
}

value() {
    printf "${GREEN}%s${RESET}\n" "$1"
}

# ===== System =====
HOSTNAME=$(hostname)

OS=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2- | tr -d '"')
KERNEL=$(uname -r)

UPTIME=$(uptime -p | sed 's/up //')

# CPU load
LOAD=$(awk '{print $1}' /proc/loadavg)

# Memory
MEM_TOTAL=$(free -h | awk '/Mem:/ {print $2}')
MEM_USED=$(free -h | awk '/Mem:/ {print $3}')
MEM_PERCENT=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')

# Disk
DISK=$(df -h / | awk 'NR==2 {print $3 " of " $2}')
DISK_PERCENT=$(df / | awk 'NR==2 {print $5}')

# CPU temperature
TEMP_FILE=$(find /sys/class/thermal -name 'temp*_input' 2>/dev/null | head -n1)

if [[ -f "$TEMP_FILE" ]]; then
    CPU_TEMP=$(awk '{printf "%.0f°C", $1/1000}' "$TEMP_FILE")
else
    CPU_TEMP="N/A"
fi

# ===== Network =====
LAN_IP=$(hostname -I | awk '{print $1}')

WAN_IP=$(curl -4 -s --max-time 2 https://api.ipify.org 2>/dev/null)
[[ -z "$WAN_IP" ]] && WAN_IP="N/A"

IPV6=$(ip -6 addr show scope global 2>/dev/null |
    awk '/inet6/ {print $2}' |
    head -n1 |
    cut -d/ -f1)

[[ -z "$IPV6" ]] && IPV6="N/A"

# ===== Packages =====
UPDATES=$(apt list --upgradable 2>/dev/null |
    tail -n +2 |
    grep -c '.')

# ===== Output =====

printf "\n"
printf "${GRAY}Packages:${RESET}       "
printf "${YELLOW}%s${RESET} ${GRAY}(%s)${RESET}\n" "$OS" "$HOSTNAME"
printf "${GRAY}Updates:${RESET}        "
printf "${YELLOW}%s${RESET} ${GRAY}packages available for upgrade${RESET}\n" "$UPDATES"
printf "${GRAY}IPv4:${RESET}           ${CYAN}(LAN)${RESET} ${GREEN}%s${RESET}  ${CYAN}(WAN)${RESET} ${GREEN}%s${RESET}\n" "$LAN_IP" "$WAN_IP"
printf "${GRAY}IPv6:${RESET}           ${GREEN}%s${RESET}\n" "$IPV6"
printf "${GRAY}Container:${RESET}      ${GREEN}%s${RESET}\n" "$HOSTNAME"
printf "\n"
printf "${GRAY}Load:${RESET}           ${GREEN}%s${RESET}" "$LOAD"
printf "                 ${GRAY}Uptime:${RESET}     ${GREEN}%s${RESET}\n" "$UPTIME"
printf "${GRAY}Memory usage:${RESET}   ${GREEN}%s of %s${RESET}" "$MEM_PERCENT%" "$MEM_TOTAL"
printf "       ${GRAY}CPU temp:${RESET}     ${GREEN}%s${RESET}\n" "$CPU_TEMP"
printf "${GRAY}Usage of /:${RESET}     ${GREEN}%s${RESET}\n" "$DISK_PERCENT of $DISK"
printf "\n"
