#!/bin/bash

# Shelby CLI + Pixabay Auto Download & Upload System
# Version: 2.0.0 - Complete Integration

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration
CONFIG_FILE="$HOME/.shelby/config.yaml"
PIXABAY_DOWNLOADER_PY="$HOME/pixabay_downloader.py"
DOWNLOAD_DIR="$HOME/pixabay_downloads"
LOG_FILE="$HOME/shelby_pixabay.log"
SHELBY_MENU_LOG="$HOME/shelby_menu.log"

# Create necessary directories
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$HOME/.shelby"

# Function to log messages
log_message() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to print header
print_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     ${WHITE}SHELBY CLI + PIXABAY AUTO DOWNLOAD & UPLOAD SYSTEM${CYAN}        ║${NC}"
    echo -e "${CYAN}║                    ${YELLOW}Complete Integration${CYAN}                         ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ============================================================================
# SHELBY CLI FUNCTIONS
# ============================================================================

# Function to check if shelby is installed
check_shelby() {
    if ! command -v shelby &> /dev/null; then
        echo -e "${RED}❌ Shelby CLI is not installed${NC}"
        echo -e "${YELLOW}Would you like to install it? (y/n)${NC}"
        read -r install_choice
        if [[ "$install_choice" =~ ^[Yy]$ ]]; then
            install_shelby
        else
            return 1
        fi
    else
        echo -e "${GREEN}✅ Shelby CLI is installed${NC}"
        return 0
    fi
}

# Function to install shelby
install_shelby() {
    print_section "INSTALL SHELBY CLI"
    
    echo -e "${CYAN}Select package manager:${NC}"
    echo "1) npm"
    echo "2) pnpm" 
    echo "3) yarn"
    echo "4) bun"
    echo "5) Back"
    
    read -r pm_choice
    
    case $pm_choice in
        1) npm i -g @shelby-protocol/cli ;;
        2) pnpm add -g @shelby-protocol/cli ;;
        3) yarn global add @shelby-protocol/cli ;;
        4) bun add --global @shelby-protocol/cli ;;
        5) return ;;
        *) echo -e "${RED}Invalid choice${NC}" ;;
    esac
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Shelby CLI installed successfully${NC}"
        log_message "Shelby CLI installed"
    else
        echo -e "${RED}❌ Installation failed${NC}"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to initialize shelby
init_shelby() {
    print_section "INITIALIZE SHELBY"
    
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}⚠️ Config file already exists at: $CONFIG_FILE${NC}"
        echo -e "Do you want to overwrite? (y/n)${NC}"
        read -r overwrite
        if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    shelby init
    log_message "Shelby initialized"
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to show version info
show_version() {
    print_section "VERSION INFORMATION"
    shelby --version
    echo -e "\n${YELLOW}Installation path:${NC}"
    which shelby
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to uninstall shelby
uninstall_shelby() {
    print_section "UNINSTALL SHELBY CLI"
    
    echo -e "${RED}⚠️ WARNING: This will remove Shelby CLI and its configuration${NC}"
    echo -e "Are you sure? (y/n)${NC}"
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Removing config directory...${NC}"
        rm -rf "$HOME/.shelby"
        
        echo -e "${YELLOW}Uninstalling global package...${NC}"
        npm uninstall -g @shelby-protocol/cli
        
        echo -e "${GREEN}✅ Shelby CLI uninstalled${NC}"
        log_message "Shelby CLI uninstalled"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to list accounts
list_accounts() {
    print_section "LIST ACCOUNTS"
    shelby account list
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to create account
create_account() {
    print_section "CREATE ACCOUNT"
    
    echo -e "${CYAN}Select mode:${NC}"
    echo "1) Interactive Mode"
    echo "2) Non-interactive Mode (specify details)"
    echo "3) Back"
    
    read -r mode_choice
    
    case $mode_choice in
        1)
            shelby account create
            log_message "Account created interactively"
            ;;
        2)
            echo -e "${YELLOW}Enter account name:${NC}"
            read -r acc_name
            echo -e "${YELLOW}Enter private key (ed25519-priv-0x...):${NC}"
            read -r priv_key
            echo -e "${YELLOW}Enter address (optional, press Enter to skip):${NC}"
            read -r address
            
            if [ -n "$address" ]; then
                shelby account create --name "$acc_name" --scheme ed25519 --private-key "$priv_key" --address "$address"
            else
                shelby account create --name "$acc_name" --scheme ed25519 --private-key "$priv_key"
            fi
            log_message "Account $acc_name created non-interactively"
            ;;
        3)
            return
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            ;;
    esac
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to use account
use_account() {
    print_section "USE ACCOUNT"
    
    echo -e "${YELLOW}Enter account name to use:${NC}"
    read -r acc_name
    
    shelby account use "$acc_name"
    log_message "Switched to account: $acc_name"
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to show balance
show_balance() {
    print_section "ACCOUNT BALANCE"
    shelby account balance
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to list blobs
list_blobs() {
    print_section "LIST BLOBS"
    shelby account blobs
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to list contexts
list_contexts() {
    print_section "LIST CONTEXTS"
    shelby context list
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to use context
use_context() {
    print_section "USE CONTEXT"
    
    echo -e "${YELLOW}Enter context name to use:${NC}"
    read -r ctx_name
    
    shelby context use "$ctx_name"
    log_message "Switched to context: $ctx_name"
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to upload file to Shelby
shelby_upload_file() {
    print_section "UPLOAD TO SHELBY"
    
    echo -e "${YELLOW}Enter source file path:${NC}"
    read -r src
    
    if [ ! -f "$src" ]; then
        echo -e "${RED}❌ File not found: $src${NC}"
        echo -e "\n${YELLOW}Press Enter to continue...${NC}"
        read
        return
    fi
    
    echo -e "${YELLOW}Enter destination blob name:${NC}"
    read -r dst
    
    echo -e "${CYAN}Expiration options:${NC}"
    echo "1) Tomorrow"
    echo "2) In 2 days"
    echo "3) Next Friday"
    echo "4) Next month"
    echo "5) Custom date"
    
    read -r exp_choice
    
    case $exp_choice in
        1) exp="tomorrow" ;;
        2) exp="in 2 days" ;;
        3) exp="next Friday" ;;
        4) exp="next month" ;;
        5) 
            echo -e "${YELLOW}Enter date (YYYY-MM-DD):${NC}"
            read -r exp
            ;;
        *)
            echo -e "${RED}Invalid choice, using 'tomorrow'${NC}"
            exp="tomorrow"
            ;;
    esac
    
    echo -e "${YELLOW}Auto-confirm payment? (y/n)${NC}"
    read -r auto_confirm
    
    cmd="shelby upload \"$src\" \"$dst\" -e \"$exp\""
    
    if [[ "$auto_confirm" =~ ^[Yy]$ ]]; then
        cmd="$cmd --assume-yes"
    fi
    
    echo -e "\n${YELLOW}Uploading...${NC}\n"
    eval $cmd
    
    if [ $? -eq 0 ]; then
        log_message "Uploaded $src to $dst (expires: $exp)"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to download from Shelby
shelby_download_file() {
    print_section "DOWNLOAD FROM SHELBY"
    
    echo -e "${YELLOW}Enter source blob name:${NC}"
    read -r src
    echo -e "${YELLOW}Enter destination file path:${NC}"
    read -r dst
    
    echo -e "${YELLOW}Force overwrite? (y/n)${NC}"
    read -r force
    
    cmd="shelby download \"$src\" \"$dst\""
    
    if [[ "$force" =~ ^[Yy]$ ]]; then
        cmd="$cmd -f"
    fi
    
    echo -e "\n${YELLOW}Downloading...${NC}\n"
    eval $cmd
    
    if [ $? -eq 0 ]; then
        log_message "Downloaded $src to $dst"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to delete from Shelby
shelby_delete_blob() {
    print_section "DELETE FROM SHELBY"
    
    echo -e "${RED}⚠️ WARNING: This will permanently delete the blob(s)${NC}"
    echo -e "${YELLOW}Enter blob name to delete:${NC}"
    read -r dst
    
    echo -e "${YELLOW}Recursive delete? (y/n)${NC}"
    read -r recursive
    
    echo -e "${YELLOW}Auto-confirm? (y/n)${NC}"
    read -r auto_confirm
    
    cmd="shelby delete \"$dst\""
    
    if [[ "$recursive" =~ ^[Yy]$ ]]; then
        cmd="$cmd -r"
    fi
    
    if [[ "$auto_confirm" =~ ^[Yy]$ ]]; then
        cmd="$cmd --assume-yes"
    fi
    
    echo -e "\n${YELLOW}Deleting...${NC}\n"
    eval $cmd
    
    if [ $? -eq 0 ]; then
        log_message "Deleted $dst from Shelby"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# ============================================================================
# PIXABAY DOWNLOADER FUNCTIONS
# ============================================================================

# Create Pixabay downloader script
create_pixabay_script() {
    if [ ! -f "$PIXABAY_DOWNLOADER_PY" ]; then
        log_message "${YELLOW}Creating Pixabay downloader script...${NC}"
        
        cat << 'EOF' > "$PIXABAY_DOWNLOADER_PY"
#!/usr/bin/env python3
import requests
import os
import sys
import time
import random
import string
import subprocess
import shutil
import json
try:
    from moviepy.editor import VideoFileClip, concatenate_videoclips
    MOVIEPY_AVAILABLE = True
except ImportError:
    MOVIEPY_AVAILABLE = False

def format_size(bytes_size):
    return f"{bytes_size/(1024*1024):.2f} MB"

def format_time(seconds):
    mins = int(seconds // 60)
    secs = int(seconds % 60)
    return f"{mins:02d}:{secs:02d}"

def draw_progress_bar(progress, total, width=50):
    percent = progress / total * 100
    filled = int(width * progress // total)
    bar = '█' * filled + '-' * (width - filled)
    return f"[{bar}] {percent:.1f}%"

def check_ffmpeg():
    return shutil.which("ffmpeg") is not None

def concatenate_with_moviepy(files, output_file):
    if not MOVIEPY_AVAILABLE:
        print("⚠️ moviepy is not installed. Cannot concatenate with moviepy.")
        return False
    try:
        clips = []
        for fn in files:
            if os.path.exists(fn) and os.path.getsize(fn) > 0:
                try:
                    clip = VideoFileClip(fn)
                    clips.append(clip)
                except Exception as e:
                    print(f"⚠️ Skipping invalid file {fn}: {str(e)}")
        if not clips:
            print("⚠️ No valid video clips to concatenate.")
            return False
        final_clip = concatenate_videoclips(clips, method="compose")
        final_clip.write_videofile(output_file, codec="libx264", audio_codec="aac", temp_audiofile="temp-audio.m4a", remove_temp=True, threads=2)
        for clip in clips:
            clip.close()
        final_clip.close()
        return os.path.exists(output_file) and os.path.getsize(output_file) > 0
    except Exception as e:
        print(f"⚠️ Moviepy concatenation failed: {str(e)}")
        return False

def download_videos(query, output_file, target_size_mb=1000, auto_upload=False, shelby_path=None, expiration="tomorrow"):
    api_key_file = os.path.expanduser('~/.pixabay_api_key')
    if not os.path.exists(api_key_file):
        print("⚠️ Pixabay API key file not found.")
        return False
        
    with open(api_key_file, 'r') as f:
        api_key = f.read().strip()
    
    per_page = 100
    downloaded_files = []
    
    try:
        # Search for videos
        url = f"https://pixabay.com/api/videos/?key={api_key}&q={query}&per_page={per_page}&min_width=1920&min_height=1080&video_type=all"
        print(f"🔍 Searching for: {query}")
        resp = requests.get(url, timeout=10)
        
        if resp.status_code != 200:
            print(f"⚠️ Error fetching Pixabay API: {resp.text}")
            return False
            
        data = resp.json()
        videos = data.get('hits', [])
        
        if not videos:
            print("⚠️ No videos found for query.")
            return False
            
        # Sort by duration (longest first)
        videos.sort(key=lambda x: x['duration'], reverse=True)
        
        total_size = 0
        target_bytes = target_size_mb * 1024 * 1024
        min_filesize = 50 * 1024 * 1024  # 50 MB minimum
        
        print(f"🎯 Target size: {format_size(target_bytes)}")
        print(f"📊 Found {len(videos)} videos\n")
        
        for i, v in enumerate(videos):
            if total_size >= target_bytes:
                break
                
            # Get video URL
            video_url = v['videos'].get('large', {}).get('url') or v['videos'].get('medium', {}).get('url')
            if not video_url:
                continue
            
            # Generate filename
            filename = f"pix_{query}_{i}_{''.join(random.choices(string.ascii_letters + string.digits, k=6))}.mp4"
            filepath = os.path.join(os.path.dirname(output_file), filename)
            
            print(f"\n🎬 Video {i+1}: {v['tags']} ({v['duration']}s)")
            
            # Get file size
            head_resp = requests.head(video_url, timeout=10)
            size = int(head_resp.headers.get('content-length', 0))
            
            if size < min_filesize:
                print(f"  ⏭️ Skipping: {format_size(size)} < 50 MB minimum")
                continue
            
            remaining = target_bytes - total_size
            if size > remaining:
                print(f"  ⏭️ Skipping: {format_size(size)} > remaining {format_size(remaining)}")
                continue
            
            # Download video
            print(f"  📥 Downloading...")
            file_start_time = time.time()
            
            resp = requests.get(video_url, stream=True, timeout=30)
            
            with open(filepath, 'wb') as f:
                downloaded = 0
                for chunk in resp.iter_content(chunk_size=8192):
                    if chunk:
                        f.write(chunk)
                        downloaded += len(chunk)
                        
                        # Show progress
                        if size > 0:
                            percent = downloaded / size * 100
                            elapsed = time.time() - file_start_time
                            speed = downloaded / (1024*1024 * elapsed) if elapsed > 0 else 0
                            eta = (size - downloaded) / (speed * 1024*1024) if speed > 0 else 0
                            
                            print(f"\r  ⬇️ Progress: {draw_progress_bar(downloaded, size)} "
                                  f"({format_size(downloaded)}/{format_size(size)}) "
                                  f"Speed: {speed:.2f} MB/s ETA: {format_time(eta)}", end='')
            
            print("\n  ✅ Download complete")
            
            file_size = os.path.getsize(filepath) if os.path.exists(filepath) else 0
            if file_size == 0:
                if os.path.exists(filepath):
                    os.remove(filepath)
                continue
            
            total_size += file_size
            downloaded_files.append(filepath)
            print(f"  📊 Total so far: {format_size(total_size)}/{format_size(target_bytes)}")
        
        if not downloaded_files:
            print("⚠️ No suitable videos downloaded.")
            return False
        
        # Combine videos if multiple
        if len(downloaded_files) == 1:
            print("\n🔗 Using single video")
            os.rename(downloaded_files[0], output_file)
        else:
            print(f"\n🔗 Combining {len(downloaded_files)} videos...")
            
            success = False
            
            # Try ffmpeg first
            if check_ffmpeg():
                print("  Using ffmpeg...")
                with open('list.txt', 'w') as f:
                    for fn in downloaded_files:
                        f.write(f"file '{fn}'\n")
                
                result = subprocess.run([
                    'ffmpeg', '-f', 'concat', '-safe', '0', 
                    '-i', 'list.txt', '-c', 'copy', output_file
                ], capture_output=True, text=True)
                
                if result.returncode == 0 and os.path.exists(output_file) and os.path.getsize(output_file) > 0:
                    success = True
                    print("  ✅ ffmpeg concatenation successful")
                else:
                    print(f"  ⚠️ ffmpeg failed: {result.stderr[:200]}...")
                
                if os.path.exists('list.txt'):
                    os.remove('list.txt')
            
            # Fallback to moviepy
            if not success:
                print("  Using moviepy...")
                success = concatenate_with_moviepy(downloaded_files, output_file)
                if success:
                    print("  ✅ moviepy concatenation successful")
            
            # If all else fails, use first video
            if not success:
                print("  ⚠️ Concatenation failed. Using first video only.")
                os.rename(downloaded_files[0], output_file)
                downloaded_files = downloaded_files[1:]
            
            # Clean up
            for fn in downloaded_files:
                if os.path.exists(fn):
                    os.remove(fn)
        
        # Verify final file
        if os.path.exists(output_file) and os.path.getsize(output_file) > 0:
            final_size = os.path.getsize(output_file)
            print(f"\n✅ Final video ready: {output_file}")
            print(f"   Size: {format_size(final_size)}")
            
            # Auto upload to Shelby if requested
            if auto_upload and shelby_path:
                print(f"\n🚀 Auto-uploading to Shelby: {shelby_path}")
                
                # Check if shelby CLI is available
                if shutil.which("shelby") is None:
                    print("  ⚠️ Shelby CLI not found. Please install it first.")
                    return True
                
                # Upload command
                upload_cmd = f'shelby upload "{output_file}" "{shelby_path}" -e "{expiration}" --assume-yes'
                
                print(f"  Running: {upload_cmd}")
                upload_result = os.system(upload_cmd)
                
                if upload_result == 0:
                    print("  ✅ Upload successful!")
                    
                    # Save upload info
                    info_file = output_file + ".info.json"
                    info = {
                        "query": query,
                        "original_file": output_file,
                        "shelby_path": shelby_path,
                        "expiration": expiration,
                        "upload_time": time.strftime("%Y-%m-%d %H:%M:%S"),
                        "file_size": final_size
                    }
                    with open(info_file, 'w') as f:
                        json.dump(info, f, indent=2)
                else:
                    print("  ⚠️ Upload failed")
            
            return True
        else:
            print("⚠️ Failed to create final video file.")
            return False
            
    except Exception as e:
        print(f"⚠️ An error occurred: {str(e)}")
        # Clean up on error
        for fn in downloaded_files:
            if os.path.exists(fn):
                os.remove(fn)
        if os.path.exists('list.txt'):
            os.remove('list.txt')
        return False

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python pixabay_downloader.py <query> <output_file> [target_size_mb] [auto_upload] [shelby_path] [expiration]")
        sys.exit(1)
    
    query = sys.argv[1]
    output_file = sys.argv[2]
    target_size_mb = int(sys.argv[3]) if len(sys.argv) > 3 else 1000
    auto_upload = sys.argv[4].lower() == 'true' if len(sys.argv) > 4 else False
    shelby_path = sys.argv[5] if len(sys.argv) > 5 else f"videos/{query}/video.mp4"
    expiration = sys.argv[6] if len(sys.argv) > 6 else "tomorrow"
    
    success = download_videos(query, output_file, target_size_mb, auto_upload, shelby_path, expiration)
    sys.exit(0 if success else 1)
EOF
        
        chmod +x "$PIXABAY_DOWNLOADER_PY"
        log_message "${GREEN}✅ Pixabay downloader script created${NC}"
    fi
}

# Function to set Pixabay API key
set_pixabay_api_key() {
    print_section "SET PIXABAY API KEY"
    
    echo -e "${YELLOW}Enter your Pixabay API key:${NC}"
    read -r api_key
    
    if [ -n "$api_key" ]; then
        echo "$api_key" > "$HOME/.pixabay_api_key"
        chmod 600 "$HOME/.pixabay_api_key"
        log_message "${GREEN}✅ API key saved${NC}"
        echo -e "${GREEN}✅ API key saved successfully${NC}"
    else
        log_message "${RED}❌ No API key provided${NC}"
        echo -e "${RED}❌ No API key provided${NC}"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to check dependencies
check_pixabay_deps() {
    print_section "CHECK PIXABAY DEPENDENCIES"
    
    echo -e "${YELLOW}Checking dependencies...${NC}\n"
    
    # Check Python
    if command -v python3 &> /dev/null; then
        echo -e "${GREEN}✅ Python3: $(python3 --version)${NC}"
    else
        echo -e "${RED}❌ Python3 not found${NC}"
        echo "Install with: sudo apt install python3 (Ubuntu/Debian) or brew install python3 (Mac)"
    fi
    
    # Check pip
    if command -v pip3 &> /dev/null; then
        echo -e "${GREEN}✅ pip3 installed${NC}"
    else
        echo -e "${RED}❌ pip3 not found${NC}"
        echo "Install with: sudo apt install python3-pip (Ubuntu/Debian)"
    fi
    
    # Check required Python packages
    echo -e "\n${YELLOW}Checking Python packages...${NC}"
    
    if python3 -c "import requests" 2>/dev/null; then
        echo -e "${GREEN}✅ requests installed${NC}"
    else
        echo -e "${RED}❌ requests not installed${NC}"
        pip3 install requests
    fi
    
    if python3 -c "import moviepy" 2>/dev/null; then
        echo -e "${GREEN}✅ moviepy installed${NC}"
    else
        echo -e "${YELLOW}⚠️ moviepy not installed (optional, for video processing)${NC}"
        echo "Install with: pip3 install moviepy"
    fi
    
    # Check ffmpeg
    echo -e "\n${YELLOW}Checking ffmpeg...${NC}"
    if command -v ffmpeg &> /dev/null; then
        echo -e "${GREEN}✅ ffmpeg: $(ffmpeg -version | head -n1)${NC}"
    else
        echo -e "${RED}❌ ffmpeg not found${NC}"
        echo "Install with: sudo apt install ffmpeg (Ubuntu/Debian) or brew install ffmpeg (Mac)"
    fi
    
    # Check API key
    echo -e "\n${YELLOW}Checking Pixabay API key...${NC}"
    if [ -f "$HOME/.pixabay_api_key" ]; then
        echo -e "${GREEN}✅ API key found${NC}"
    else
        echo -e "${RED}❌ API key not found${NC}"
        echo "Please set your API key in the menu"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function for single Pixabay download
pixabay_single_download() {
    print_section "PIXABAY SINGLE DOWNLOAD"
    
    echo -e "${YELLOW}Enter search query:${NC}"
    read -r query
    
    if [ -z "$query" ]; then
        echo -e "${RED}❌ Query cannot be empty${NC}"
        echo -e "\n${YELLOW}Press Enter to continue...${NC}"
        read
        return
    fi
    
    # Generate output filename
    timestamp=$(date +%Y%m%d_%H%M%S)
    output_file="$DOWNLOAD_DIR/${query// /_}_${timestamp}.mp4"
    
    echo -e "${YELLOW}Target size in MB (default: 1000):${NC}"
    read -r target_size
    target_size=${target_size:-1000}
    
    echo -e "${YELLOW}Auto upload to Shelby? (y/n):${NC}"
    read -r auto_upload
    
    shelby_path=""
    expiration="tomorrow"
    
    if [[ "$auto_upload" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Shelby path (default: videos/${query}/video.mp4):${NC}"
        read -r shelby_path
        shelby_path=${shelby_path:-"videos/${query}/video.mp4"}
        
        echo -e "${YELLOW}Expiration (default: tomorrow):${NC}"
        read -r expiration
        expiration=${expiration:-"tomorrow"}
    fi
    
    echo -e "\n${YELLOW}Starting download...${NC}\n"
    
    python3 "$PIXABAY_DOWNLOADER_PY" "$query" "$output_file" "$target_size" "${auto_upload,,}" "$shelby_path" "$expiration"
    
    if [ $? -eq 0 ]; then
        log_message "Pixabay download completed: $query -> $output_file"
        echo -e "\n${GREEN}✅ Download complete! File saved to: $output_file${NC}"
    else
        log_message "Pixabay download failed: $query"
        echo -e "\n${RED}❌ Download failed${NC}"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function for batch Pixabay download
pixabay_batch_download() {
    print_section "PIXABAY BATCH DOWNLOAD"
    
    echo -e "${YELLOW}Enter path to query file (one query per line):${NC}"
    read -r query_file
    
    if [ ! -f "$query_file" ]; then
        echo -e "${RED}❌ File not found: $query_file${NC}"
        echo -e "\n${YELLOW}Press Enter to continue...${NC}"
        read
        return
    fi
    
    echo -e "${YELLOW}Target size per video in MB (default: 500):${NC}"
    read -r target_size
    target_size=${target_size:-500}
    
    echo -e "${YELLOW}Auto upload to Shelby? (y/n):${NC}"
    read -r auto_upload
    
    expiration="tomorrow"
    if [[ "$auto_upload" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Expiration (default: tomorrow):${NC}"
        read -r expiration
        expiration=${expiration:-"tomorrow"}
    fi
    
    # Create batch directory
    batch_dir="$DOWNLOAD_DIR/batch_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$batch_dir"
    
    log_message "${YELLOW}Starting batch download from $query_file${NC}"
    
    while IFS= read -r query || [ -n "$query" ]; do
        if [ -n "$query" ]; then
            echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${WHITE}Processing: $query${NC}"
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
            
            # Clean filename
            clean_query=$(echo "$query" | tr -cd '[:alnum:] _-' | tr ' ' '_')
            output_file="$batch_dir/${clean_query}_$(date +%s).mp4"
            
            shelby_path="videos/${clean_query}/video.mp4"
            
            python3 "$PIXABAY_DOWNLOADER_PY" "$query" "$output_file" "$target_size" "${auto_upload,,}" "$shelby_path" "$expiration"
            
            log_message "${GREEN}✅ Completed: $query${NC}"
        fi
    done < "$query_file"
    
    log_message "${GREEN}✅ Batch download complete! Files saved in: $batch_dir${NC}"
    
    echo -e "\n${GREEN}✅ Batch download complete! Files saved in: $batch_dir${NC}"
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to list downloaded videos
list_downloaded_videos() {
    print_section "DOWNLOADED VIDEOS"
    
    if [ -d "$DOWNLOAD_DIR" ]; then
        echo -e "${WHITE}Directory: $DOWNLOAD_DIR${NC}\n"
        
        # Count files
        file_count=$(find "$DOWNLOAD_DIR" -type f -name "*.mp4" | wc -l)
        total_size=$(find "$DOWNLOAD_DIR" -type f -name "*.mp4" -exec du -b {} \; | awk '{total+=$1} END {print total}')
        
        echo -e "Total videos: ${GREEN}$file_count${NC}"
        echo -e "Total size: ${GREEN}$(echo "scale=2; $total_size/1024/1024/1024" | bc) GB${NC}\n"
        
        # List recent files
        echo -e "${WHITE}Recent downloads:${NC}"
        find "$DOWNLOAD_DIR" -type f -name "*.mp4" -printf "%T@ %p\n" 2>/dev/null | sort -nr | head -10 | while read -r line; do
            file=$(echo "$line" | cut -d' ' -f2-)
            if [ -f "$file" ]; then
                size=$(du -h "$file" 2>/dev/null | cut -f1)
                mod_time=$(stat -c "%y" "$file" 2>/dev/null | cut -d. -f1)
                echo -e "  ${CYAN}•${NC} $(basename "$file") ${YELLOW}($size)${NC} - $mod_time"
            fi
        done
        
        # Show upload info files
        echo -e "\n${WHITE}Uploaded to Shelby:${NC}"
        find "$DOWNLOAD_DIR" -type f -name "*.info.json" -printf "%T@ %p\n" 2>/dev/null | sort -nr | head -5 | while read -r line; do
            info_file=$(echo "$line" | cut -d' ' -f2-)
            if [ -f "$info_file" ]; then
                shelby_path=$(grep -o '"shelby_path": "[^"]*"' "$info_file" 2>/dev/null | cut -d'"' -f4)
                upload_time=$(grep -o '"upload_time": "[^"]*"' "$info_file" 2>/dev/null | cut -d'"' -f4)
                echo -e "  ${GREEN}✓${NC} $shelby_path - $upload_time"
            fi
        done
        
    else
        echo -e "${YELLOW}No downloads yet${NC}"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to clean old files
clean_old_pixabay_files() {
    print_section "CLEAN OLD FILES"
    
    echo -e "${YELLOW}Delete files older than (days):${NC}"
    read -r days
    
    if [ -n "$days" ] && [ "$days" -gt 0 ]; then
        echo -e "\n${RED}This will delete files older than $days days${NC}"
        echo -e "Are you sure? (y/n):${NC}"
        read -r confirm
        
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            find "$DOWNLOAD_DIR" -type f -name "*.mp4" -mtime +$days -delete 2>/dev/null
            find "$DOWNLOAD_DIR" -type f -name "*.info.json" -mtime +$days -delete 2>/dev/null
            log_message "${GREEN}✅ Deleted files older than $days days${NC}"
            echo -e "${GREEN}✅ Deleted files older than $days days${NC}"
        fi
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to print section header
print_section() {
    echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  $1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# ============================================================================
# MAIN MENU SYSTEM
# ============================================================================

# Main menu
main_menu() {
    # Create Pixabay script if not exists
    create_pixabay_script
    
    while true; do
        print_header
        
        echo -e "${WHITE}MAIN MENU${NC}\n"
        
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${WHITE}  SHELBY CLI MANAGEMENT${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}1)${NC} Check/Install Shelby CLI"
        echo -e "${GREEN}2)${NC} Initialize Shelby"
        echo -e "${GREEN}3)${NC} Version Info & Path"
        echo -e "${GREEN}4)${NC} Account Management"
        echo -e "${GREEN}5)${NC} Context Management"
        echo -e "${GREEN}6)${NC} File Operations (Upload/Download)"
        echo -e "${GREEN}7)${NC} Uninstall Shelby"
        
        echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${WHITE}  PIXABAY AUTO DOWNLOAD & UPLOAD${NC}"
        echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${PURPLE}8)${NC} Set Pixabay API Key"
        echo -e "${PURPLE}9)${NC} Check Pixabay Dependencies"
        echo -e "${PURPLE}10)${NC} Single Video Download"
        echo -e "${PURPLE}11)${NC} Batch Download from File"
        echo -e "${PURPLE}12)${NC} List Downloaded Videos"
        echo -e "${PURPLE}13)${NC} Clean Old Files"
        
        echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${WHITE}  INTEGRATED FEATURES${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}14)${NC} Download & Auto-Upload to Shelby"
        echo -e "${BLUE}15)${NC} View Upload Status"
        echo -e "${BLUE}16)${NC} View Log File"
        
        echo -e "\n${RED}17)${NC} Exit\n"
        
        echo -e "${YELLOW}Select an option [1-17]:${NC} "
        read -r main_choice
        
        case $main_choice in
            1) check_shelby; echo -e "\n${YELLOW}Press Enter to continue...${NC}"; read ;;
            2) init_shelby ;;
            3) show_version ;;
            4) account_menu ;;
            5) context_menu ;;
            6) file_menu ;;
            7) uninstall_shelby ;;
            8) set_pixabay_api_key ;;
            9) check_pixabay_deps ;;
            10) pixabay_single_download ;;
            11) pixabay_batch_download ;;
            12) list_downloaded_videos ;;
            13) clean_old_pixabay_files ;;
            14) integrated_download_upload ;;
            15) show_upload_status ;;
            16) view_log ;;
            17)
                log_message "${GREEN}Exiting...${NC}"
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

# Account menu
account_menu() {
    while true; do
        print_header
        print_section "ACCOUNT MANAGEMENT"
        
        echo -e "${CYAN}1)${NC} List Accounts"
        echo -e "${CYAN}2)${NC} Create Account"
        echo -e "${CYAN}3)${NC} Use Account (Set Default)"
        echo -e "${CYAN}4)${NC} Show Balance"
        echo -e "${CYAN}5)${NC} List Blobs"
        echo -e "${CYAN}6)${NC} Back to Main Menu\n"
        
        echo -e "${YELLOW}Select an option [1-6]:${NC} "
        read -r acc_choice
        
        case $acc_choice in
            1) list_accounts ;;
            2) create_account ;;
            3) use_account ;;
            4) show_balance ;;
            5) list_blobs ;;
            6) return ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

# Context menu
context_menu() {
    while true; do
        print_header
        print_section "CONTEXT MANAGEMENT"
        
        echo -e "${PURPLE}1)${NC} List Contexts"
        echo -e "${PURPLE}2)${NC} Use Context (Set Default)"
        echo -e "${PURPLE}3)${NC} Back to Main Menu\n"
        
        echo -e "${YELLOW}Select an option [1-3]:${NC} "
        read -r ctx_choice
        
        case $ctx_choice in
            1) list_contexts ;;
            2) use_context ;;
            3) return ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

# File operations menu
file_menu() {
    while true; do
        print_header
        print_section "FILE OPERATIONS"
        
        echo -e "${BLUE}1)${NC} Upload File to Shelby"
        echo -e "${BLUE}2)${NC} Download File from Shelby"
        echo -e "${BLUE}3)${NC} Delete Blob from Shelby"
        echo -e "${BLUE}4)${NC} Back to Main Menu\n"
        
        echo -e "${YELLOW}Select an option [1-4]:${NC} "
        read -r file_choice
        
        case $file_choice in
            1) shelby_upload_file ;;
            2) shelby_download_file ;;
            3) shelby_delete_blob ;;
            4) return ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

# Integrated download and upload
integrated_download_upload() {
    print_section "DOWNLOAD & AUTO-UPLOAD TO SHELBY"
    
    echo -e "${YELLOW}Enter search query:${NC}"
    read -r query
    
    if [ -z "$query" ]; then
        echo -e "${RED}❌ Query cannot be empty${NC}"
        echo -e "\n${YELLOW}Press Enter to continue...${NC}"
        read
        return
    fi
    
    # Generate output filename
    timestamp=$(date +%Y%m%d_%H%M%S)
    output_file="$DOWNLOAD_DIR/${query// /_}_${timestamp}.mp4"
    
    echo -e "${YELLOW}Target size in MB (default: 1000):${NC}"
    read -r target_size
    target_size=${target_size:-1000}
    
    echo -e "${YELLOW}Shelby path (default: videos/${query}/video.mp4):${NC}"
    read -r shelby_path
    shelby_path=${shelby_path:-"videos/${query}/video.mp4"}
    
    echo -e "${YELLOW}Expiration (default: tomorrow):${NC}"
    read -r expiration
    expiration=${expiration:-"tomorrow"}
    
    echo -e "\n${YELLOW}Starting download with auto-upload...${NC}\n"
    
    python3 "$PIXABAY_DOWNLOADER_PY" "$query" "$output_file" "$target_size" "true" "$shelby_path" "$expiration"
    
    if [ $? -eq 0 ]; then
        log_message "Integrated download & upload completed: $query -> $shelby_path"
        echo -e "\n${GREEN}✅ Process completed successfully!${NC}"
    else
        log_message "Integrated process failed: $query"
        echo -e "\n${RED}❌ Process failed${NC}"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Show upload status
show_upload_status() {
    print_section "UPLOAD STATUS"
    
    if command -v shelby &> /dev/null; then
        echo -e "${WHITE}Current Shelby Account:${NC}"
        shelby account list | grep "(default)" -B 1 -A 1 2>/dev/null
        
        echo -e "\n${WHITE}Recent Uploads:${NC}"
        shelby account blobs 2>/dev/null | head -20
        
        echo -e "\n${WHITE}Account Balance:${NC}"
        shelby account balance 2>/dev/null
    else
        echo -e "${RED}❌ Shelby CLI not installed${NC}"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# View log file
view_log() {
    print_section "LOG FILE"
    
    if [ -f "$LOG_FILE" ]; then
        echo -e "${WHITE}Last 50 log entries:${NC}\n"
        tail -50 "$LOG_FILE"
        echo -e "\n${YELLOW}Log file: $LOG_FILE${NC}"
    else
        echo -e "${YELLOW}No log file found${NC}"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Start the menu system
main_menu
