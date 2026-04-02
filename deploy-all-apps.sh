#!/bin/bash
set -e

APP_DIR="$HOME/multi-language-webapps"

echo "========================================"
echo "Updating system packages..."
echo "========================================"
sudo dnf update -y || sudo yum update -y

echo "========================================"
echo "Installing runtimes and tools..."
echo "========================================"
sudo dnf install -y git python3 python3-pip nodejs npm php php-cli ruby ruby-devel gcc gcc-c++ make java-17-amazon-corretto maven sqlite || \
sudo yum install -y git python3 python3-pip nodejs npm php php-cli ruby ruby-devel gcc gcc-c++ make java-17-amazon-corretto maven sqlite

echo "========================================"
echo "Installing Ruby gems for Sinatra..."
echo "========================================"
sudo gem install sinatra webrick rackup puma

echo "========================================"
echo "Verifying installed versions..."
echo "========================================"
python3 --version || true
node -v || true
npm -v || true
php -v || true
ruby -v || true
java -version || true
mvn -v || true
sqlite3 --version || true

echo "========================================"
echo "Cloning or updating repository..."
echo "========================================"
if [ ! -d "$APP_DIR" ]; then
  git clone https://github.com/owotee/multi-language-webapps.git "$APP_DIR"
else
  cd "$APP_DIR"
  git pull
fi

cd "$APP_DIR"

echo "========================================"
echo "Stopping old app processes..."
echo "========================================"
pkill -f "python3 app.py" || true
pkill -f "node app.js" || true
pkill -f "php -S 0.0.0.0:5003" || true
pkill -f "ruby app.rb" || true
pkill -f "mvn exec:java" || true
pkill -f "java -jar" || true

########################################
# Python App
########################################
echo "========================================"
echo "Deploying Python app..."
echo "========================================"
cd "$APP_DIR/python-app"
ls -la

if [ -f "requirements.txt" ]; then
  pip3 install -r requirements.txt
else
  echo "requirements.txt not found, installing Flask directly..."
  pip3 install flask
fi

rm -f python.log
nohup python3 app.py > python.log 2>&1 &
sleep 5

echo "Python log:"
cat python.log || true

echo "Testing Python app on port 5001..."
curl http://localhost:5001 || true

########################################
# Node App
########################################
echo "========================================"
echo "Deploying Node app..."
echo "========================================"
cd "$APP_DIR/node-app"
ls -la
npm install

rm -f node.log
nohup node app.js > node.log 2>&1 &
sleep 5

echo "Node log:"
cat node.log || true

echo "Testing Node app on port 5002..."
curl http://localhost:5002 || true

########################################
# PHP App
########################################
echo "========================================"
echo "Deploying PHP app..."
echo "========================================"
cd "$APP_DIR/php-app"
ls -la

rm -f php.log
nohup php -S 0.0.0.0:5003 > php.log 2>&1 &
sleep 5

echo "PHP log:"
cat php.log || true

echo "Testing PHP app on port 5003..."
curl http://localhost:5003 || true

########################################
# Ruby App
########################################
echo "========================================"
echo "Deploying Ruby app..."
echo "========================================"
cd "$APP_DIR/ruby-app"
ls -la

if [ -f "Gemfile" ]; then
  bundle install
else
  echo "No Gemfile found. Skipping bundle install."
fi

sudo gem install sinatra webrick rackup puma

echo "Verifying webrick..."
ruby -e "require 'webrick'; puts 'webrick ok'"

rm -f ruby.log
nohup ruby app.rb -o 0.0.0.0 -p 5004 > ruby.log 2>&1 &
sleep 5

echo "Ruby log:"
cat ruby.log || true

echo "Testing Ruby app on port 5004..."
curl http://localhost:5004 || true

########################################
# Java App
########################################
echo "========================================"
echo "Deploying Java app..."
echo "========================================"
cd "$APP_DIR/java-app"
ls -la

mvn clean compile

rm -f java.log
nohup mvn exec:java > java.log 2>&1 &
sleep 10

echo "Java log:"
cat java.log || true

echo "Testing Java app on port 5005..."
curl http://localhost:5005 || true

########################################
# Final Checks
########################################
echo "========================================"
echo "Checking running processes..."
echo "========================================"
ps -ef | grep -E "python3|node|php|ruby|java|mvn" | grep -v grep || true

echo "========================================"
echo "Checking listening ports..."
echo "========================================"
ss -tulpn | grep -E '5001|5002|5003|5004|5005' || true

echo "========================================"
echo "Deployment complete."
echo "Test the apps in your browser:"
echo "http://YOUR_PUBLIC_IP:5001"
echo "http://YOUR_PUBLIC_IP:5002"
echo "http://YOUR_PUBLIC_IP:5003"
echo "http://YOUR_PUBLIC_IP:5004"
echo "http://YOUR_PUBLIC_IP:5005"
echo "========================================"

# ========================================
# Multi-Language Web Apps Deployment Script
# ========================================
#
# This script installs all required runtimes and deploys:
# - Python Flask app on port 5001
# - Node.js app on port 5002
# - PHP app on port 5003
# - Ruby Sinatra app on port 5004
# - Java app on port 5005
#
# Required Security Group Inbound Rules:
# - SSH        : 22
# - Python App : 5001
# - Node App   : 5002
# - PHP App    : 5003
# - Ruby App   : 5004
# - Java App   : 5005
#
# Required Packages Installed:
# - git
# - python3 / pip
# - nodejs / npm
# - php
# - ruby
# - java-17-amazon-corretto
# - maven
# - sqlite
#
# Troubleshooting Notes
# ========================================
#
# Python App Issues
# -----------------
# Check the background process log:
# cat python.log
# If requirements.txt is missing:
# pip3 install flask
#
# Ruby App Issues
# -----------------
# Error:
# Could not locate Gemfile
# Cause:
# Bundler was run in a directory without a Gemfile.
# Fix:
# Skip bundle install if there is no Gemfile.
#
# Error:
# cannot load such file -- sinatra (LoadError)
# Cause:
# Sinatra gem missing.
# Fix:
# sudo gem install sinatra
#
# Error:
# cannot load such file -- webrick (LoadError)
# Cause:
# Webrick gem missing.
# Fix:
# sudo gem install webrick
#
# Error:
# Ruby log still shows old webrick error
# Cause:
# Old crash log or stale process.
# Fix:
# rm -f ruby.log
# ruby -e "require 'webrick'; puts 'webrick ok'"
# Restart the Ruby app
#
# Error:
# Sinatra could not start, required gems weren't found...
# Cause:
# rackup and puma missing.
# Fix:
# sudo gem install rackup puma
#
# Java App Issues
# -----------------
# If the Java app fails to start:
# cat java.log
#
# Make sure Maven is installed:
# mvn -v
#
# Run manually:
# cd ~/multi-language-webapps/java-app
# mvn clean compile
# mvn exec:java
#
# General Verification Commands
# -----------------
# Check running processes:
# ps -ef | grep -E "python3|node|php|ruby|java|mvn"
#
# Check listening ports:
# ss -tulpn | grep -E '5001|5002|5003|5004|5005'
#
# Test locally on the EC2 instance:
# curl http://localhost:5001
# curl http://localhost:5002
# curl http://localhost:5003
# curl http://localhost:5004
# curl http://localhost:5005
# ========================================