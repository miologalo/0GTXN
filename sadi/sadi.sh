#!/bin/bash

# Shelby CLI + Pixabay Auto Download & Upload System
# Version: 2.2.0 - Fixed Version for Node.js Issues

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

# Shelby Testnet Configuration
SHELBY_TESTNET_RPC="https://api.testnet.shelby.xyz/shelby"
SHELBY_TESTNET_APTOS_FULLNODE="https://api.testnet.aptoslabs.com/v1"
SHELBY_TESTNET_APTOS_INDEXER="https://api.testnet.aptoslabs.com/v1/graphql"
SHELBY_TESTNET_FAUCET="https://faucet.testnet.shelby.xyz"
SHELBY_EXPLORER="https://explorer.shelby.xyz/testnet"

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
    echo -e "${CYAN}║                    ${YELLOW}Fixed Version - Node.js Compatible${CYAN}          ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Function to fix Node.js version issues
fix_node_issues() {
    print_section "FIXING NODE.JS ISSUES"
    
    echo -e "${YELLOW}Checking Node.js version...${NC}"
    NODE_VERSION=$(node --version)
    echo -e "Current Node.js version: ${CYAN}$NODE_VERSION${NC}"
    
    # Check if using Node.js v24+
    if [[ "$NODE_VERSION" == v24* ]]; then
        echo -e "${YELLOW}⚠️ You are using Node.js v24 which may have compatibility issues.${NC}"
        echo -e "${YELLOW}Suggestions:${NC}"
        echo -e "1) Use nvm to switch to Node.js v20 or v22"
        echo -e "2) Or continue with current version (some features may not work)"
        echo ""
        
        echo -e "${CYAN}Do you want to switch to Node.js v20 using nvm? (y/n)${NC}"
        read -r switch_node
        
        if [[ "$switch_node" =~ ^[Yy]$ ]]; then
            if command -v nvm &> /dev/null; then
                echo -e "${YELLOW}Installing and using Node.js v20...${NC}"
                nvm install 20
                nvm use 20
                echo -e "${GREEN}✅ Switched to Node.js v20${NC}"
            else
                echo -e "${RED}❌ nvm not found. Please install nvm or manually switch Node.js version${NC}"
                echo -e "Visit: https://github.com/nvm-sh/nvm"
            fi
        fi
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to manually configure Shelby Testnet
manual_configure_testnet() {
    print_section "MANUAL SHELBY TESTNET CONFIGURATION"
    
    echo -e "${YELLOW}Creating Shelby Testnet configuration manually...${NC}\n"
    
    # Check if config file exists
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${YELLOW}Creating new config file...${NC}"
        mkdir -p "$HOME/.shelby"
        
        # Create base config
        cat > "$CONFIG_FILE" << EOF
contexts:
  shelby-testnet:
    aptos_network:
      name: testnet
      fullnode: https://api.testnet.aptoslabs.com/v1
      indexer: https://api.testnet.aptoslabs.com/v1/graphql
      faucet: https://faucet.testnet.shelby.xyz
      pepper: https://api.testnet.aptoslabs.com/keyless/pepper/v0
      prover: https://api.testnet.aptoslabs.com/keyless/prover/v0
    shelby_network:
      rpc_endpoint: https://api.testnet.shelby.xyz/shelby
  local:
    aptos_network:
      name: local
      fullnode: http://127.0.0.1:8080/v1
      faucet: http://127.0.0.1:8081
      indexer: http://127.0.0.1:8090/v1/graphql
    shelby_network:
      rpc_endpoint: http://localhost:9090/
  shelbynet:
    aptos_network:
      name: shelbynet
      fullnode: https://api.shelbynet.shelby.xyz/v1
      faucet: https://faucet.shelbynet.shelby.xyz
      indexer: https://api.shelbynet.shelby.xyz/v1/graphql
    shelby_network:
      rpc_endpoint: https://api.shelbynet.shelby.xyz/shelby

accounts: {}
default_context: shelby-testnet
EOF
        
        echo -e "${GREEN}✅ Config file created at: $CONFIG_FILE${NC}"
    else
        echo -e "${YELLOW}Config file exists. Adding Shelby Testnet configuration...${NC}"
        
        # Check if shelby-testnet already exists
        if grep -q "shelby-testnet" "$CONFIG_FILE"; then
            echo -e "${GREEN}✅ Shelby Testnet already configured${NC}"
        else
            # Backup config
            cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
            
            # Append configuration
            cat >> "$CONFIG_FILE" << EOF

  shelby-testnet:
    aptos_network:
      name: testnet
      fullnode: https://api.testnet.aptoslabs.com/v1
      indexer: https://api.testnet.aptoslabs.com/v1/graphql
      faucet: https://faucet.testnet.shelby.xyz
      pepper: https://api.testnet.aptoslabs.com/keyless/pepper/v0
      prover: https://api.testnet.aptoslabs.com/keyless/prover/v0
    shelby_network:
      rpc_endpoint: https://api.testnet.shelby.xyz/shelby
EOF
            
            # Update default context
            sed -i 's/default_context:.*/default_context: shelby-testnet/' "$CONFIG_FILE"
            
            echo -e "${GREEN}✅ Shelby Testnet added to config${NC}"
        fi
    fi
    
    echo -e "\n${YELLOW}Current configuration:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Extract and display important info
    if command -v shelby &> /dev/null; then
        shelby context list 2>/dev/null || echo -e "${YELLOW}Run 'shelby context list' manually${NC}"
    else
        echo -e "${YELLOW}Contexts configured:${NC}"
        grep -E "^  [a-zA-Z0-9-]+:" "$CONFIG_FILE" | sed 's/://g' | sed 's/^  //g'
    fi
    
    echo -e "\n${GREEN}✅ Shelby Testnet is now configured as default${NC}"
    log_message "Manually configured Shelby Testnet"
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to check current configuration
check_config() {
    print_section "CHECK CONFIGURATION"
    
    echo -e "${WHITE}Config file: ${CYAN}$CONFIG_FILE${NC}\n"
    
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${WHITE}Current default context:${NC}"
        DEFAULT_CONTEXT=$(grep "default_context:" "$CONFIG_FILE" | cut -d' ' -f2)
        echo -e "${GREEN}$DEFAULT_CONTEXT${NC}\n"
        
        echo -e "${WHITE}Available contexts:${NC}"
        grep -E "^  [a-zA-Z0-9-]+:" "$CONFIG_FILE" | sed 's/://g' | sed 's/^  //g' | while read -r ctx; do
            if [ "$ctx" = "$DEFAULT_CONTEXT" ]; then
                echo -e "  ${GREEN}✓ $ctx (default)${NC}"
            else
                echo -e "  ${CYAN}• $ctx${NC}"
            fi
        done
        
        echo -e "\n${WHITE}Accounts:${NC}"
        if grep -q "accounts:" "$CONFIG_FILE"; then
            # Extract accounts section
            in_accounts=false
            while IFS= read -r line; do
                if [[ "$line" =~ ^accounts: ]]; then
                    in_accounts=true
                elif [[ "$in_accounts" == true && "$line" =~ ^[[:space:]]+[a-zA-Z0-9]+: ]]; then
                    acc_name=$(echo "$line" | sed 's/://g' | sed 's/^[[:space:]]*//g')
                    echo -e "  ${GREEN}✓ $acc_name${NC}"
                elif [[ "$in_accounts" == true && ! "$line" =~ ^[[:space:]] ]]; then
                    in_accounts=false
                fi
            done < "$CONFIG_FILE"
        else
            echo -e "  ${YELLOW}No accounts found${NC}"
        fi
        
        # Check default account
        DEFAULT_ACCOUNT=$(grep "default_account:" "$CONFIG_FILE" 2>/dev/null | cut -d' ' -f2)
        if [ -n "$DEFAULT_ACCOUNT" ]; then
            echo -e "\n${WHITE}Default account: ${GREEN}$DEFAULT_ACCOUNT${NC}"
        fi
        
    else
        echo -e "${RED}❌ Config file not found${NC}"
        echo -e "${YELLOW}Please run Option 2 to create configuration${NC}"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to switch to Shelby Testnet
switch_to_shelby_testnet() {
    print_section "SWITCH TO SHELBY TESTNET"
    
    # First try manual configuration
    manual_configure_testnet
    
    # Try to use the context with shelby CLI
    if command -v shelby &> /dev/null; then
        echo -e "\n${YELLOW}Attempting to switch using Shelby CLI...${NC}"
        
        # Use a different approach to avoid the stdin issue
        echo -e "shelby-testnet" | shelby context use shelby-testnet 2>/dev/null || {
            echo -e "${YELLOW}CLI command failed, but manual config is set.${NC}"
            echo -e "${GREEN}✅ Configuration is ready in $CONFIG_FILE${NC}"
        }
        
        # Update default context in config file directly
        if [ -f "$CONFIG_FILE" ]; then
            sed -i 's/default_context:.*/default_context: shelby-testnet/' "$CONFIG_FILE"
            echo -e "${GREEN}✅ Default context set to shelby-testnet in config file${NC}"
        fi
    fi
    
    echo -e "\n${GREEN}✅ Shelby Testnet is now configured as default${NC}"
    log_message "Switched to Shelby Testnet"
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to get ShelbyUSD tokens from faucet
get_shelbyusd_faucet() {
    print_section "GET SHELBYUSD TOKENS"
    
    echo -e "${YELLOW}Opening ShelbyUSD faucet for your account...${NC}\n"
    
    # Try to get address from config
    ADDRESS=""
    
    # First try from shelby CLI
    if command -v shelby &> /dev/null; then
        ACCOUNT_INFO=$(shelby account list 2>/dev/null | grep "(default)" -B 1)
        ADDRESS=$(echo "$ACCOUNT_INFO" | grep -o '0x[a-f0-9]\+' | head -1)
    fi
    
    # If not found, ask user
    if [ -z "$ADDRESS" ]; then
        echo -e "${YELLOW}Could not detect account address.${NC}"
        echo -e "${YELLOW}Please enter your account address (from your screenshot):${NC}"
        echo -e "${CYAN}0x0a913975d02df90df926b80559c973cdba72c592e116e3ff76df95f0d02a1f2${NC}"
        read -r ADDRESS
        
        if [ -z "$ADDRESS" ]; then
            ADDRESS="0x0a913975d02df90df926b80559c973cdba72c592e116e3ff76df95f0d02a1f2"
        fi
    fi
    
    if [ -n "$ADDRESS" ]; then
        echo -e "\n${WHITE}Your account address:${NC}"
        echo -e "${CYAN}${ADDRESS}${NC}"
        
        echo -e "\n${YELLOW}Faucet URL:${NC}"
        FAUCET_URL="https://faucet.testnet.shelby.xyz/?address=${ADDRESS}"
        echo -e "${CYAN}${FAUCET_URL}${NC}"
        
        echo -e "\n${YELLOW}Opening in browser...${NC}"
        
        # Try different browsers
        if command -v xdg-open &> /dev/null; then
            xdg-open "$FAUCET_URL"
        elif command -v open &> /dev/null; then
            open "$FAUCET_URL"
        elif command -v firefox &> /dev/null; then
            firefox "$FAUCET_URL"
        elif command -v google-chrome &> /dev/null; then
            google-chrome "$FAUCET_URL"
        else
            echo -e "${RED}Please manually open this URL:${NC}"
            echo "$FAUCET_URL"
        fi
        
        echo -e "\n${GREEN}✅ After getting tokens, you can check balance${NC}"
    else
        echo -e "${RED}❌ No address provided${NC}"
    fi
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to check balance (using curl instead of shelby CLI)
check_balance_curl() {
    print_section "CHECK BALANCE (via API)"
    
    ADDRESS="0x0a913975d02df90df926b80559c973cdba72c592e116e3ff76df95f0d02a1f2"
    
    echo -e "${WHITE}Checking balance for address:${NC}"
    echo -e "${CYAN}$ADDRESS${NC}\n"
    
    echo -e "${YELLOW}Checking APT balance...${NC}"
    curl -s "https://api.testnet.aptoslabs.com/v1/accounts/$ADDRESS" | python3 -m json.tool 2>/dev/null || echo -e "${RED}Failed to fetch APT balance${NC}"
    
    echo -e "\n${YELLOW}Checking ShelbyUSD balance...${NC}"
    SHELBYUSD_ADDRESS="0x1b18363a9f1fe5e6ebf247daba5cc1c18052bb232efdc4c50f556053922d98e1"
    curl -s "https://api.testnet.aptoslabs.com/v1/accounts/$ADDRESS/coin/$SHELBYUSD_ADDRESS" | python3 -m json.tool 2>/dev/null || echo -e "${YELLOW}No ShelbyUSD balance found${NC}"
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to create account manually
create_account_manual() {
    print_section "CREATE ACCOUNT MANUALLY"
    
    echo -e "${YELLOW}Enter account name:${NC}"
    read -r acc_name
    
    if [ -z "$acc_name" ]; then
        echo -e "${RED}❌ Account name required${NC}"
        echo -e "\n${YELLOW}Press Enter to continue...${NC}"
        read
        return
    fi
    
    echo -e "${YELLOW}Enter private key (or press Enter to generate new):${NC}"
    read -r priv_key
    
    if [ -z "$priv_key" ]; then
        # Generate a random private key (this is just for demo - use proper generation in production)
        echo -e "${YELLOW}Generating new account...${NC}"
        
        # Add to config
        if [ -f "$CONFIG_FILE" ]; then
            # Generate random address (demo only)
            RANDOM_ADDR="0x$(openssl rand -hex 32 2>/dev/null || echo "0a913975d02df90df926b80559c973cdba72c592e116e3ff76df95f0d02a1f2")"
            
            # Add to config
            cat >> "$CONFIG_FILE" << EOF

accounts:
  $acc_name:
    private_key: ed25519-priv-0x$(openssl rand -hex 64 2>/dev/null || echo "8a1b2c3d4e5f...")
    address: "$RANDOM_ADDR"
default_account: $acc_name
EOF
            echo -e "${GREEN}✅ Account '$acc_name' created in config${NC}"
            echo -e "${YELLOW}Address: $RANDOM_ADDR${NC}"
            echo -e "${YELLOW}Note: This is a demo address. For real use, generate properly.${NC}"
        else
            echo -e "${RED}❌ Config file not found. Run Option 2 first.${NC}"
        fi
    else
        # Add existing key to config
        if [ -f "$CONFIG_FILE" ]; then
            echo -e "${YELLOW}Enter address:${NC}"
            read -r address
            
            cat >> "$CONFIG_FILE" << EOF

accounts:
  $acc_name:
    private_key: $priv_key
    address: "$address"
default_account: $acc_name
EOF
            echo -e "${GREEN}✅ Account '$acc_name' added to config${NC}"
        fi
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
    
    echo -e "\n${YELLOW}Starting download...${NC}\n"
    
    python3 "$PIXABAY_DOWNLOADER_PY" "$query" "$output_file" "$target_size" "false" "" ""
    
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

# Function to list downloaded videos
list_downloaded_videos() {
    print_section "DOWNLOADED VIDEOS"
    
    if [ -d "$DOWNLOAD_DIR" ]; then
        echo -e "${WHITE}Directory: $DOWNLOAD_DIR${NC}\n"
        
        # Count files
        file_count=$(find "$DOWNLOAD_DIR" -type f -name "*.mp4" | wc -l)
        
        echo -e "Total videos: ${GREEN}$file_count${NC}\n"
        
        # List recent files
        echo -e "${WHITE}Recent downloads:${NC}"
        ls -lt "$DOWNLOAD_DIR"/*.mp4 2>/dev/null | head -10 | while read -r line; do
            file=$(echo "$line" | awk '{print $NF}')
            size=$(du -h "$file" 2>/dev/null | cut -f1)
            echo -e "  ${CYAN}•${NC} $(basename "$file") ${YELLOW}($size)${NC}"
        done
        
    else
        echo -e "${YELLOW}No downloads yet${NC}"
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

# Function to upload to Shelby using curl
upload_with_curl() {
    print_section "UPLOAD FILE TO SHELBY (via curl)"
    
    echo -e "${YELLOW}Enter file path to upload:${NC}"
    read -r filepath
    
    if [ ! -f "$filepath" ]; then
        echo -e "${RED}❌ File not found${NC}"
        echo -e "\n${YELLOW}Press Enter to continue...${NC}"
        read
        return
    fi
    
    echo -e "${YELLOW}Enter destination path:${NC}"
    read -r dest
    
    # Get address from config
    ADDRESS=$(grep -A 2 "default_account" "$CONFIG_FILE" 2>/dev/null | grep "address" | cut -d'"' -f2)
    if [ -z "$ADDRESS" ]; then
        ADDRESS="0x0a913975d02df90df926b80559c973cdba72c592e116e3ff76df95f0d02a1f2"
    fi
    
    echo -e "\n${YELLOW}This feature requires Shelby CLI. Please use Option 7 from main menu.${NC}"
    
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# ============================================================================
# MAIN MENU
# ============================================================================

# Main menu
main_menu() {
    # Create Pixabay script if not exists
    create_pixabay_script
    
    while true; do
        print_header
        
        echo -e "${WHITE}MAIN MENU - SHELBY TESTNET (Fixed Version)${NC}\n"
        
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${WHITE}  SHELBY TESTNET CONFIGURATION${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}1)${NC} Fix Node.js Version Issues"
        echo -e "${GREEN}2)${NC} Configure Shelby Testnet (Manual)"
        echo -e "${GREEN}3)${NC} Check Configuration"
        echo -e "${GREEN}4)${NC} Get ShelbyUSD from Faucet"
        
        echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${WHITE}  ACCOUNT MANAGEMENT${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}5)${NC} Create Account (Manual)"
        echo -e "${CYAN}6)${NC} Check Balance (via API)"
        
        echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${WHITE}  PIXABAY DOWNLOAD${NC}"
        echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${PURPLE}7)${NC} Set Pixabay API Key"
        echo -e "${PURPLE}8)${NC} Single Video Download"
        echo -e "${PURPLE}9)${NC} List Downloaded Videos"
        
        echo -e "\n${RED}10)${NC} Exit\n"
        
        echo -e "${YELLOW}Select an option [1-10]:${NC} "
        read -r main_choice
        
        case $main_choice in
            1) fix_node_issues ;;
            2) switch_to_shelby_testnet ;;
            3) check_config ;;
            4) get_shelbyusd_faucet ;;
            5) create_account_manual ;;
            6) check_balance_curl ;;
            7) set_pixabay_api_key ;;
            8) pixabay_single_download ;;
            9) list_downloaded_videos ;;
            10)
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

# Start the menu system
main_menu
