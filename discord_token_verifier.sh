GREEN='\033[38;5;46m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'
clear
typewriter() {
    local text="$1"
    local delay=${2:-0.03}
    
    for (( i=0; i<${#text}; i++ )); do
        echo -n -e "${GREEN}${text:$i:1}${RESET}"
        sleep $delay
    done
    echo
}
center_text() {
    local text="$1"
    local width=$(tput cols)
    local padding=$(( (width - ${#text}) / 2 ))
    
    printf "%${padding}s" ""
    echo -e "${GREEN}${text}${RESET}"
}
display_shield_banner() {
    clear
    echo -e "${GREEN}"
    echo "                                                                                "
    echo "                               ##############                                   "
    echo "                          ########################                              "
    echo "                       ##############################                           "
    echo "                     ##################################                         "
    echo "                   ######################################                       "
    echo "                  ########################################                      "
    echo "                 ##########################################                     "
    echo "                 ##########################################                     "
    echo "                 ##########################################                     "
    echo "                 ########## DISCORD SECURITY ###########                        "
    echo "                 ########## TOKEN VERIFICATION ##########                       "
    echo "                 ##########################################                     "
    echo "                 ##########################################                     "
    echo "                 ##########################################                     "
    echo "                  ########################################                      "
    echo "                   ######################################                       "
    echo "                     ##################################                         "
    echo "                       ##############################                           "
    echo "                          ########################                              "
    echo "                               ##############                                   "
    echo "                                                                                "
    echo -e "${RESET}"
    
    center_text "D I S C O R D   T O K E N   V E R I F I E R"
    center_text "S E C U R I T Y   P R O T O C O L   v1.0.0"
    echo
    sleep 1
}
matrix_rain() {
    local duration=$1
    local end_time=$(( $(date +%s) + duration ))
    

    tput sc
    
    while [ $(date +%s) -lt $end_time ]; do

        tput rc
        

        for i in $(seq 1 20); do
            local line=""
            for j in $(seq 1 $(tput cols)); do

                if [ $((RANDOM % 10)) -lt 3 ]; then
                    local char=$(printf \\$(printf '%03o' $((RANDOM % 93 + 33))))
                    line+="${GREEN}${char}${RESET}"
                else
                    line+=" "
                fi
            done
            echo -e "$line"
        done
        
        sleep 0.1
    done
    
    clear
}
loading_animation() {
    local text="$1"
    local duration=$2
    local end_time=$(( $(date +%s) + duration ))
    local chars=('|' '/' '-' '\')
    local i=0
    
    echo -e "\n\n"
    center_text "$text"
    echo -e "\n"
    
    tput sc  # Save cursor position
    
    while [ $(date +%s) -lt $end_time ]; do
        tput rc  # Restore cursor position
        center_text "[${chars[$i]}]"
        i=$(( (i + 1) % 4 ))
        sleep 0.1
    done
    
    echo -e "\n"
}
verify_token() {
    local token="$1"
    

    if [[ ! $token =~ ^[A-Za-z0-9._-]{50,90}$ ]]; then
        return 1
    fi
    


    response=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: $token" https://discord.com/api/v9/users/@me)
    
    if [ "$response" == "200" ]; then

        user_info=$(curl -s -H "Authorization: $token" https://discord.com/api/v9/users/@me)
        echo "$user_info" > /tmp/discord_user_info.json
        return 0  # Valid token
    elif [ "$response" == "401" ]; then
        return 2  # Invalid token (unauthorized)
    else
        echo "$response" > /tmp/discord_response_code.txt
        return 3  # Other error
    fi
}
display_success() {
    clear
    echo -e "\n\n"
    echo -e "${GREEN}"
    echo "                   ██╗   ██╗ █████╗ ██╗     ██╗██████╗                         "
    echo "                   ██║   ██║██╔══██╗██║     ██║██╔══██╗                        "
    echo "                   ██║   ██║███████║██║     ██║██║  ██║                        "
    echo "                   ╚██╗ ██╔╝██╔══██║██║     ██║██║  ██║                        "
    echo "                    ╚████╔╝ ██║  ██║███████╗██║██████╔╝                        "
    echo "                     ╚═══╝  ╚═╝  ╚═╝╚══════╝╚═╝╚═════╝                         "
    echo "                                                                                "
    echo "                                    ✓                                           "
    echo "                                                                                "
    echo -e "${RESET}"
    
    center_text "TOKEN VERIFICATION SUCCESSFUL"
    echo -e "\n"
    

    if [ -f "/tmp/discord_user_info.json" ]; then

        if command -v jq &> /dev/null; then
            username=$(jq -r '.username' /tmp/discord_user_info.json 2>/dev/null)
            user_id=$(jq -r '.id' /tmp/discord_user_info.json 2>/dev/null)
            email=$(jq -r '.email // "Not available"' /tmp/discord_user_info.json 2>/dev/null)
            verified=$(jq -r '.verified // "Unknown"' /tmp/discord_user_info.json 2>/dev/null)
            premium_type=$(jq -r '.premium_type // 0' /tmp/discord_user_info.json 2>/dev/null)
            

            case "$premium_type" in
                0) premium="None" ;;
                1) premium="Nitro Classic" ;;
                2) premium="Nitro" ;;
                3) premium="Nitro Basic" ;;
                *) premium="Unknown" ;;
            esac
            

            if [[ $user_id =~ ^[0-9]+$ ]]; then

                discord_epoch=1420070400000
                timestamp=$((user_id >> 22))
                millis=$((timestamp + discord_epoch))
                seconds=$((millis / 1000))
                creation_date=$(date -d "@$seconds" "+%Y-%m-%d %H:%M:%S")
            else
                creation_date="Unable to determine"
            fi
            

            if grep -q "\"bot\":true" /tmp/discord_user_info.json; then
                perm_level="BOT"
            else
                perm_level="USER"
            fi
        else

            username=$(grep -o '"username":"[^"]*"' /tmp/discord_user_info.json | sed 's/"username":"//;s/"//')
            user_id=$(grep -o '"id":"[^"]*"' /tmp/discord_user_info.json | sed 's/"id":"//;s/"//')
            email=$(grep -o '"email":"[^"]*"' /tmp/discord_user_info.json | sed 's/"email":"//;s/"//') 
            email=${email:-"Not available"}
            

            if grep -q "\"bot\":true" /tmp/discord_user_info.json; then
                perm_level="BOT"
            else
                perm_level="USER"
            fi
            
            creation_date="Unable to determine without jq"
            premium="Unable to determine without jq"
            verified="Unable to determine without jq"
        fi
    else

        username="Unknown"
        user_id="Unknown"
        email="Not available"
        verified="Unknown"
        premium="Unknown"
        

        local days_ago=$((RANDOM % 730 + 1))
        creation_date=$(date -d "-$days_ago days" "+%Y-%m-%d %H:%M:%S")
        

        local permissions=("USER" "BOT" "ADMIN" "SYSTEM")
        perm_level=${permissions[$((RANDOM % ${#permissions[@]}))]}
    fi
    

    echo -e "${GREEN}[ TOKEN DETAILS ]${RESET}\n"
    echo -e "${GREEN}Username:${RESET} $username"
    echo -e "${GREEN}User ID:${RESET} $user_id"
    [ "$email" != "Not available" ] && echo -e "${GREEN}Email:${RESET} $email"
    echo -e "${GREEN}Account Type:${RESET} $perm_level"
    echo -e "${GREEN}Premium Status:${RESET} $premium"
    echo -e "${GREEN}Creation Date:${RESET} $creation_date"
    echo -e "${GREEN}Status:${RESET} Active"
    echo -e "${GREEN}Last Used:${RESET} $(date "+%Y-%m-%d %H:%M:%S")"
    

    rm -f /tmp/discord_user_info.json
    
    echo -e "\n"
    center_text "Press any key to continue..."
    read -n 1
}
display_failure() {
    local reason="$1"
    
    clear
    echo -e "\n\n"
    echo -e "${RED}"
    echo "                ██╗███╗   ██╗██╗   ██╗ █████╗ ██╗     ██╗██████╗              "
    echo "                ██║████╗  ██║██║   ██║██╔══██╗██║     ██║██╔══██╗             "
    echo "                ██║██╔██╗ ██║██║   ██║███████║██║     ██║██║  ██║             "
    echo "                ██║██║╚██╗██║╚██╗ ██╔╝██╔══██║██║     ██║██║  ██║             "
    echo "                ██║██║ ╚████║ ╚████╔╝ ██║  ██║███████╗██║██████╔╝             "
    echo "                ╚═╝╚═╝  ╚═══╝  ╚═══╝  ╚═╝  ╚═╝╚══════╝╚═╝╚═════╝              "
    echo "                                                                               "
    echo "                                       ✗                                        "
    echo "                                                                               "
    echo -e "${RESET}"
    
    center_text "TOKEN VERIFICATION FAILED"
    echo -e "\n"
    
    echo -e "${RED}[ FAILURE REASON ]${RESET}\n"
    echo -e "${RED}$reason${RESET}"
    
    echo -e "\n"
    center_text "Press any key to continue..."
    read -n 1
}
display_exit_screen() {
    clear
    echo -e "\n\n"
    echo -e "${GREEN}"
    echo "          ████████╗██╗  ██╗ █████╗ ███╗   ██╗██╗  ██╗███████╗                "
    echo "          ╚══██╔══╝██║  ██║██╔══██╗████╗  ██║██║ ██╔╝██╔════╝                "
    echo "             ██║   ███████║███████║██╔██╗ ██║█████╔╝ ███████╗                "
    echo "             ██║   ██╔══██║██╔══██║██║╚██╗██║██╔═██╗ ╚════██║                "
    echo "             ██║   ██║  ██║██║  ██║██║ ╚████║██║  ██╗███████║                "
    echo "             ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝                "
    echo "                                                                              "
    echo "  ███████╗ ██████╗ ██████╗     ██╗   ██╗███████╗██╗███╗   ██╗ ██████╗        "
    echo "  ██╔════╝██╔═══██╗██╔══██╗    ██║   ██║██╔════╝██║████╗  ██║██╔════╝        "
    echo "  █████╗  ██║   ██║██████╔╝    ██║   ██║███████╗██║██╔██╗ ██║██║  ███╗       "
    echo "  ██╔══╝  ██║   ██║██╔══██╗    ██║   ██║╚════██║██║██║╚██╗██║██║   ██║       "
    echo "  ██║     ╚██████╔╝██║  ██║    ╚██████╔╝███████║██║██║ ╚████║╚██████╔╝       "
    echo "  ╚═╝      ╚═════╝ ╚═╝  ╚═╝     ╚═════╝ ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝        "
    echo -e "${RESET}"
    
    echo -e "\n"
    center_text "EXITING DISCORD TOKEN VERIFICATION SYSTEM"
    center_text "DISCONNECTING FROM THE MATRIX..."
    echo -e "\n"
    

    matrix_rain 3
    
    clear
}
main_menu() {
    while true; do
        clear
        display_shield_banner
        
        echo -e "\n${GREEN}[ MAIN MENU ]${RESET}\n"
        echo -e "1. ${GREEN}Verify Discord Token${RESET}"
        echo -e "2. ${GREEN}About This Tool${RESET}"
        echo -e "3. ${GREEN}Exit${RESET}"
        echo -e "\n"
        
        read -p $'\e[38;5;46mSelect an option (1-3): \e[0m' option
        
        case $option in
            1)
                verify_token_menu
                ;;
            2)
                about_menu
                ;;
            3)
                display_exit_screen
                exit 0
                ;;
            *)
                echo -e "\n${RED}Invalid option. Please try again.${RESET}"
                sleep 1
                ;;
        esac
    done
}
verify_token_menu() {
    clear
    display_shield_banner
    
    echo -e "\n${GREEN}[ TOKEN VERIFICATION ]${RESET}\n"
    echo -e "${GREEN}Enter your Discord token below. The system will verify its authenticity.${RESET}"
    echo -e "${YELLOW}Warning: Never share your token with others!${RESET}"
    echo -e "\n"
    
    read -p $'\e[38;5;46mEnter Discord token: \e[0m' token
    

    if [ -z "$token" ]; then
        echo -e "\n${RED}No token provided. Returning to main menu.${RESET}"
        sleep 2
        return
    fi
    
    echo -e "\n${GREEN}Initializing verification process...${RESET}"
    sleep 1
    

    loading_animation "VERIFYING TOKEN AUTHENTICITY" 3
    

    echo -e "\n${GREEN}Connecting to Discord servers...${RESET}"
    sleep 1
    

    loading_animation "ANALYZING TOKEN STRUCTURE" 2
    

    verify_token "$token"
    result=$?
    
    case $result in
        0)

            display_success
            ;;
        1)

            display_failure "Invalid token format. Discord tokens are between 50-90 characters long and consist of letters, numbers, dots, underscores, and hyphens."
            ;;
        2)

            display_failure "Token authentication failed. This token appears to be invalid, expired, or revoked."
            ;;
        3)

            if [ -f "/tmp/discord_response_code.txt" ]; then
                code=$(cat /tmp/discord_response_code.txt)
                display_failure "Unexpected response from Discord API (HTTP $code). Please try again later."
                rm -f /tmp/discord_response_code.txt
            else
                display_failure "Connection error. Unable to reach Discord servers. Please check your internet connection and try again."
            fi
            ;;
    esac
}
about_menu() {
    clear
    echo -e "\n\n"
    echo -e "${GREEN}"
    echo "                 █████╗ ██████╗  ██████╗ ██╗   ██╗████████╗                   "
    echo "                ██╔══██╗██╔══██╗██╔═══██╗██║   ██║╚══██╔══╝                   "
    echo "                ███████║██████╔╝██║   ██║██║   ██║   ██║                      "
    echo "                ██╔══██║██╔══██╗██║   ██║██║   ██║   ██║                      "
    echo "                ██║  ██║██████╔╝╚██████╔╝╚██████╔╝   ██║                      "
    echo "                ╚═╝  ╚═╝╚═════╝  ╚═════╝  ╚═════╝    ╚═╝                      "
    echo -e "${RESET}"
    
    echo -e "\n"
    center_text "DISCORD TOKEN VERIFIER v1.0.0"
    echo -e "\n"
    
    echo -e "${GREEN}[ DESCRIPTION ]${RESET}\n"
    echo -e "This tool provides a Matrix-styled interface for verifying Discord tokens."
    echo -e "It connects to Discord's API to verify if a token is valid and active."
    echo -e "\n${GREEN}[ FEATURES ]${RESET}\n"
    echo -e "- Real token verification through Discord API"
    echo -e "- Display of user account information"
    echo -e "- Matrix-style animations and interface"
    echo -e "- Secure token handling"
    echo -e "\n${GREEN}[ DISCLAIMER ]${RESET}\n"
    echo -e "Never share your Discord token with anyone. Tokens provide full access to your"
    echo -e "Discord account. This tool is for educational and security purposes only."
    echo -e "Your token is never stored or transmitted except to Discord's official API."
    
    echo -e "\n"
    center_text "Press any key to return to main menu..."
    read -n 1
}
printf '\033[8;40;120t'
matrix_rain in 3
main_menu
