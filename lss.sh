#!/bin/bash

# رنگ‌های زیبا
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# آیکون‌ها
FOLDER="📁"
FILE="📄"
SCRIPT="🐚"
PYTHON="🐍"
EXECUTABLE="🚀"
CONFIG="⚙️"
DATABASE="🗄️"
TEXT="📝"
ARCHIVE="📦"
HOME_ICON="🏠"
BACK_ICON="↩️"
RUN_ICON="▶️"
COMMAND_ICON="💻"

current_dir="."
show_files=true

show_header() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════╗"
    echo "║          🗂️ TERMUX EXPLORER 🗂️         ║"
    echo "║      Folder & Tool Manager v2.0       ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${YELLOW}📂 Current: ${BLUE}$current_dir${NC}"
    echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
    
    if [[ "$show_files" == true ]]; then
        echo -e "${GREEN}║               📋 FOLDERS & TOOLS 📋               ║${NC}"
    else
        echo -e "${GREEN}║                    📋 FOLDERS 📋                  ║${NC}"
    fi
    
    echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
}

get_icon() {
    local item="$1"
    local full_path="$2"
    
    if [[ -d "$full_path" ]]; then
        echo "$FOLDER"
    elif [[ -x "$full_path" ]]; then
        echo "$EXECUTABLE"
    elif [[ "$item" == *.sh ]]; then
        echo "$SCRIPT"
    elif [[ "$item" == *.py ]]; then
        echo "$PYTHON"
    elif [[ "$item" == *.js ]]; then
        echo "📜"
    elif [[ "$item" == *.php ]]; then
        echo "🐘"
    elif [[ "$item" == *.json ]] || [[ "$item" == *.config ]]; then
        echo "$CONFIG"
    elif [[ "$item" == *.db ]] || [[ "$item" == *.sqlite ]]; then
        echo "$DATABASE"
    elif [[ "$item" == *.txt ]] || [[ "$item" == *.md ]]; then
        echo "$TEXT"
    elif [[ "$item" == *.zip ]] || [[ "$item" == *.tar* ]]; then
        echo "$ARCHIVE"
    else
        echo "$FILE"
    fi
}

get_color() {
    local item="$1"
    local full_path="$2"
    
    if [[ -d "$full_path" ]]; then
        echo "$BLUE"
    elif [[ -x "$full_path" ]]; then
        echo "$GREEN"
    elif [[ "$item" == *.sh ]] || [[ "$item" == *.py ]]; then
        echo "$YELLOW"
    elif [[ "$item" == *.json ]] || [[ "$item" == *.config ]]; then
        echo "$PURPLE"
    else
        echo "$WHITE"
    fi
}

get_type() {
    local item="$1"
    local full_path="$2"
    
    if [[ -d "$full_path" ]]; then
        echo "DIR"
    elif [[ -x "$full_path" ]]; then
        echo "EXE"
    elif [[ "$item" == *.sh ]]; then
        echo "SHELL"
    elif [[ "$item" == *.py ]]; then
        echo "PYTHON"
    elif [[ "$item" == *.js ]]; then
        echo "NODEJS"
    elif [[ "$item" == *.php ]]; then
        echo "PHP"
    else
        echo "FILE"
    fi
}

list_items() {
    local dir="$1"
    local items=()
    local folders=()
    local files=()
    
    # خواندن تمام آیتم‌ها
    while IFS= read -r item; do
        [[ -z "$item" ]] && continue
        local full_path="$dir/$item"
        
        if [[ -d "$full_path" ]]; then
            folders+=("$item")
        elif [[ "$show_files" == true ]]; then
            files+=("$item")
        fi
    done < <(ls -A "$dir" 2>/dev/null)
    
    # ترکیب پوشه‌ها و فایل‌ها
    items=("${folders[@]}")
    if [[ "$show_files" == true ]]; then
        items+=("${files[@]}")
    fi
    
    if [[ ${#items[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No items found!${NC}"
        return 1
    fi
    
    # نمایش آیتم‌ها
    for i in "${!items[@]}"; do
        local item="${items[$i]}"
        local full_path="$dir/$item"
        local icon=$(get_icon "$item" "$full_path")
        local color=$(get_color "$item" "$full_path")
        local type=$(get_type "$item" "$full_path")
        
        # اطلاعات اضافی
        local info=""
        if [[ -d "$full_path" ]]; then
            local item_count=$(find "$full_path" -maxdepth 1 | wc -l)
            info="[${item_count} items]"
        elif [[ -f "$full_path" ]]; then
            local size=$(du -h "$full_path" 2>/dev/null | cut -f1)
            info="[${size}]"
        fi
        
        printf "${PURPLE}%3d.${NC} ${icon} ${color}%-25s${NC} ${YELLOW}%-10s${NC} ${CYAN}%s${NC}\n" \
               $((i+1)) "$item" "[$type]" "$info"
    done
    
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
    
    local folder_count=${#folders[@]}
    local file_count=${#files[@]}
    
    if [[ "$show_files" == true ]]; then
        echo -e "${GREEN}║     📊 TOTAL: ${folder_count} folders, ${file_count} files     ║${NC}"
    else
        echo -e "${GREEN}║             📊 TOTAL: ${folder_count} folders            ║${NC}"
    fi
    
    echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
    
    return ${#items[@]}
}

enter_folder() {
    local choice="$1"
    local dir="$2"
    local items=()
    
    # جمع‌آوری لیست آیتم‌ها
    while IFS= read -r item; do
        [[ -z "$item" ]] && continue
        local full_path="$dir/$item"
        if [[ -d "$full_path" ]]; then
            items+=("$item")
        elif [[ "$show_files" == true ]]; then
            items+=("$item")
        fi
    done < <(ls -A "$dir" 2>/dev/null)
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}❌ Invalid number! Please enter a valid number${NC}"
        sleep 2
        return 1
    fi
    
    if [[ "$choice" -lt 1 ]] || [[ "$choice" -gt "${#items[@]}" ]]; then
        echo -e "${RED}❌ Number out of range!${NC}"
        sleep 2
        return 1
    fi
    
    local selected_item="${items[$((choice-1))]}"
    local full_path="$dir/$selected_item"
    
    if [[ -d "$full_path" ]]; then
        current_dir="$full_path"
        echo -e "${GREEN}✅ Entering folder: ${BLUE}$selected_item${NC}"
        sleep 1
    else
        echo -e "${RED}❌ Not a folder!${NC}"
        sleep 2
    fi
}

run_tool() {
    local choice="$1"
    local dir="$2"
    local items=()
    
    # جمع‌آوری لیست آیتم‌ها
    while IFS= read -r item; do
        [[ -z "$item" ]] && continue
        local full_path="$dir/$item"
        if [[ -f "$full_path" ]] && ([[ -x "$full_path" ]] || 
           [[ "$item" == *.sh ]] || [[ "$item" == *.py ]] || 
           [[ "$item" == *.js ]] || [[ "$item" == *.php ]]); then
            items+=("$item")
        fi
    done < <(ls -A "$dir" 2>/dev/null)
    
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}❌ Invalid number!${NC}"
        sleep 2
        return 1
    fi
    
    if [[ "$choice" -lt 1 ]] || [[ "$choice" -gt "${#items[@]}" ]]; then
        echo -e "${RED}❌ Number out of range!${NC}"
        sleep 2
        return 1
    fi
    
    local selected_tool="${items[$((choice-1))]}"
    local full_path="$dir/$selected_tool"
    
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           ${RUN_ICON} RUNNING TOOL ${RUN_ICON}           ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo -e "${GREEN}🔧 Tool: ${YELLOW}$selected_tool${NC}"
    echo -e "${GREEN}📁 Path: ${YELLOW}$full_path${NC}"
    echo -e "${GREEN}⏰ Time: ${YELLOW}$(date)${NC}"
    echo -e "${CYAN}══════════════════════════════════════════${NC}"
    echo ""
    
    # اجرای ابزار
    cd "$(dirname "$full_path")"
    chmod +x "$full_path" 2>/dev/null
    
    case "$selected_tool" in
        *.sh)
            bash "$full_path"
            ;;
        *.py)
            python "$full_path"
            ;;
        *.js)
            node "$full_path"
            ;;
        *.php)
            php "$full_path"
            ;;
        *)
            "./$selected_tool"
            ;;
    esac
    
    local exit_code=$?
    
    echo ""
    echo -e "${CYAN}══════════════════════════════════════════${NC}"
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}✅ Tool executed successfully ✅${NC}"
    else
        echo -e "${YELLOW}⚠️ Tool exited with code: $exit_code ⚠️${NC}"
    fi
    echo -e "${CYAN}══════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Press Enter to continue...${NC}"
    read
}

execute_command() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          ${COMMAND_ICON} COMMAND MODE ${COMMAND_ICON}          ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo -e "${YELLOW}Current directory: ${BLUE}$current_dir${NC}"
    echo -e "${GREEN}Enter command (or 'exit' to return):${NC}"
    echo ""
    
    while true; do
        echo -e -n "${YELLOW}💻 ${current_dir} > ${NC}"
        read -r cmd
        
        if [[ "$cmd" == "exit" ]] || [[ "$cmd" == "quit" ]]; then
            break
        elif [[ -n "$cmd" ]]; then
            echo -e "${CYAN}────────────────────────────────────────────────${NC}"
            eval "$cmd"
            echo -e "${CYAN}────────────────────────────────────────────────${NC}"
        fi
    done
}

main_menu() {
    while true; do
        show_header
        list_items "$current_dir"
        local item_count=$?
        
        echo ""
        echo -e "${YELLOW}🎮 OPTIONS:${NC}"
        
        if [[ $item_count -gt 0 ]]; then
            echo -e "  ${GREEN}[1-${item_count}]${NC} Enter folder / Run tool"
        fi
        
        echo -e "  ${GREEN}[r1-${item_count}]${NC} Run tool directly"
        echo -e "  ${GREEN}[b]${NC} Back to parent folder"
        echo -e "  ${GREEN}[h]${NC} Go to HOME directory"
        echo -e "  ${GREEN}[t]${NC} Toggle files view (当前: ${show_files})"
        echo -e "  ${GREEN}[c]${NC} Command mode"
        echo -e "  ${GREEN}[q]${NC} Quit"
        echo ""
        echo -e "${YELLOW}Enter your choice: ${NC}"
        read -r choice
        
        case "$choice" in
            [0-9]*)
                if [[ $item_count -gt 0 ]]; then
                    enter_folder "$choice" "$current_dir"
                else
                    echo -e "${RED}❌ No items available!${NC}"
                    sleep 2
                fi
                ;;
            r[0-9]*)
                if [[ $item_count -gt 0 ]]; then
                    local tool_num="${choice#r}"
                    run_tool "$tool_num" "$current_dir"
                else
                    echo -e "${RED}❌ No tools available!${NC}"
                    sleep 2
                fi
                ;;
            b|B)
                if [[ "$current_dir" != "." ]]; then
                    current_dir=$(dirname "$current_dir")
                    echo -e "${GREEN}↩️ Returning to parent folder${NC}"
                    sleep 1
                else
                    echo -e "${YELLOW}⚠️ Already at root directory${NC}"
                    sleep 1
                fi
                ;;
            h|H)
                current_dir="$HOME"
                echo -e "${GREEN}🏠 Going to HOME directory${NC}"
                sleep 1
                ;;
            t|T)
                if [[ "$show_files" == true ]]; then
                    show_files=false
                    echo -e "${BLUE}📁 Showing folders only${NC}"
                else
                    show_files=true
                    echo -e "${BLUE}📋 Showing folders and files${NC}"
                fi
                sleep 1
                ;;
            c|C)
                execute_command
                ;;
            q|Q)
                echo -e "${GREEN}👋 Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Invalid choice!${NC}"
                sleep 2
                ;;
        esac
    done
}

# اجرای اصلی
if [[ -n "$1" ]]; then
    current_dir="$1"
fi

main_menu
