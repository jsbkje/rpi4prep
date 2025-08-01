#!/bin/bash
set -e

echo "🔧 Updating system and installing build tools..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
  git build-essential autoconf automake libtool pkg-config \
  libusb-1.0-0-dev libncurses5-dev libreadline-dev \
  libsigrok-dev libudev-dev libusb-dev \
  libasio-dev libcppunit-dev python3 python3-pip python3-venv

echo "📡 Cloning and building Hamlib from GitHub..."
cd /usr/local/src
sudo git clone https://github.com/Hamlib/Hamlib.git
cd Hamlib
sudo ./bootstrap
sudo ./configure
sudo make -j$(nproc)
sudo make install
sudo ldconfig

echo "✅ rigctl installed at: $(command -v rigctl)"
rigctl -V || echo "rigctl not found—check install path"

echo "🌐 Installing Webmin and Usermin..."
curl -fsSL https://download.webmin.com/jcameron-key.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/webmin.gpg
echo "deb http://download.webmin.com/download/repository sarge contrib" | sudo tee /etc/apt/sources.list.d/webmin.list
sudo apt update
sudo apt install -y webmin usermin

echo "🐍 Setting up Python virtual environment for dashboard..."
mkdir -p ~/rigdash
cd ~/rigdash
python3 -m venv venv
source venv/bin/activate

echo "📦 Installing Python packages: Flask, requests, Jinja2..."
pip install --upgrade pip
pip install flask requests jinja2

echo "🎉 Setup complete!"
echo "🔗 Webmin:   https://<your-pi-ip>:10000"
echo "🔗 Usermin:  https://<your-pi-ip>:20000"
echo "🌀 Flask env ready: source ~/rigdash/venv/bin/activate"
