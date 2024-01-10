#!/bin/bash

GREEN="\e[32m"
END="\e[0m"
echo -e "${GREEN}Setting up WSL environment for AOSP builds${END}"

function apt-update () {
    sudo apt install lsb-release -y
    echo -e "${GREEN}You're currently running:${END}"
    lsb_release -a
    sleep 1.0
    echo -e "${GREEN}Fetching updates...${END}"
    sudo apt update -qq
    sleep 1.0
    echo -e "${GREEN}Installing updates...${END}"
    sudo apt upgrade -qq -y
} 
apt-update

function install-git () {
    echo -e "${GREEN}Installing Git...${END}"
    sleep 1.0
    sudo apt install -y -qq git git-lfs
    sleep 1.0
}
install-git

function main-install () {
    echo -e "${GREEN}Installing packages...${END}"
    sleep 1.0
    sudo DEBIAN_FRONTEND=noninteractive \
    apt install \
    autoconf automake axel bc bison build-essential \
    ccache clang cmake curl expat fastboot flex g++ \
    g++-multilib gawk gcc gcc-multilib gnupg gperf \
    htop imagemagick libncurses5 lib32z1-dev libtinfo5 libc6-dev libcap-dev \
    libexpat1-dev libgmp-dev '^liblz4-.*' '^liblzma.*' libmpc-dev libmpfr-dev \
    libsdl1.2-dev libssl-dev libtool libxml2 libxml2-utils '^lzma.*' lzop \
    maven ncftp ncurses-dev patch patchelf pkg-config pngcrush \
    pngquant python3-pip python3-venv re2c schedtool squashfs-tools subversion \
    texinfo unzip w3m xsltproc zip zlib1g-dev lzip \
    libxml-simple-perl libswitch-perl apt-utils rsync \
    neofetch alien jq man musl binwalk xmlstarlet default-jdk pydf \
    detox htop wget llvm netcat-traditional fio dwarves zstd \
    -y -qq
}

function git-setup () {
    echo -e "${GREEN}Setting up Git profile...${END}"
    git config --global user.name "Sourajit Karmakar"
    git config --global user.email "sourajit.karmakar@gmail.com"
}
git-setup

function git-template () {
    echo -e "${GREEN}Setting up global Change-Id hook...${END}"
    mkdir -p ~/.git-templates/hooks/
    echo -e "${GREEN}Downloading commit-msg hook...${END}"
    wget https://android-review.googlesource.com/tools/hooks/commit-msg -O ~/.git-templates/hooks/commit-msg
    echo -e "${GREEN}Making commit-msg hook executable...${END}"
    sudo chmod +x ~/.git-templates/hooks/commit-msg
    echo -e "${GREEN}Configuring Git to use the hook...${END}"
    git config --global init.templatedir '~/.git-templates'
    sleep 0.8
    echo -e "${GREEN}Done! Repos cloned from here on will have the hook installed.${END}"    
}
git-template 

function ohmyzsh () {
    echo -e "${GREEN}Setting up Oh My Zsh...${END}"
    sudo apt install zsh curl -y
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" | bash <(sed -n '82,$p' setup.sh)
}
ohmyzsh

function link-python2-python3 () {
    echo -e "${GREEN}Linking Python -> Python3${END}"
    sleep 1.0
    sudo ln -s /usr/bin/python3 /usr/bin/python
}
link-python2-python3

function setting-up-repo () {
    echo -e "${GREEN}Setting up repo...${END}"
    mkdir -p ~/bin/repo
    export REPO=$(mktemp /tmp/repo.XXXXXXXXX)
    curl -o ${REPO} https://storage.googleapis.com/git-repo-downloads/repo
    gpg --recv-keys 8BB9AD793E8E6153AF0F9A4416530D5E920F5C65
    curl -s https://storage.googleapis.com/git-repo-downloads/repo.asc | gpg --verify - ${REPO} && install -m 755 ${REPO} ~/bin/repo
}
setting-up-repo

function wsl-specific () {
    echo -e "${GREEN}Setting default user and excluding Windows PATH...${END}"
    sudo echo "[user]
    default = prince
    appendWindowsPath = false" > /etc/wsl.conf
}
wsl-specific

function setup-apktool () {
    echo -e "${GREEN}Setting up APKtool...${END}"
    local url_stem="https://github.com/iBotPeaches/Apktool/releases"
    local latest_tag=$(curl -s https://api.github.com/repos/iBotPeaches/Apktool/releases/latest | jq -r '.tag_name' | sed 's/^v//')
    wget -q --show-progress ${url_stem}/download/v${latest_tag}/apktool_${latest_tag}.jar -O apktool.jar
    wget -q --show-progress https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O apktool
    sudo chmod +x apktool
    sudo mv apktool apktool.jar /usr/local/bin
    echo -e "${GREEN}Apktool $(apktool --version) installed!${END}"
}
setup-apktool

function setup-jadx () {
    echo -e "${GREEN}Setting up Jadx...${END}"
    JADX_VERSION=$(curl -s "https://api.github.com/repos/skylot/jadx/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
    curl -Lo jadx.zip "https://github.com/skylot/jadx/releases/latest/download/jadx-${JADX_VERSION}.zip"
    unzip jadx.zip -d jadx-temp
    sudo mkdir -p /opt/jadx/bin
    sudo cp -r jadx-temp/bin/jadx /opt/jadx/bin/
    sudo cp -r jadx-temp/lib /opt/jadx
    export PATH=$PATH:/opt/jadx/bin/ | sudo tee -a /etc/profile
    source /etc/profile
    echo -e "${GREEN}Jadx $(jadx --version) installed!${END}"
}
setup-jadx
echo -e "Setup is now complete!"
