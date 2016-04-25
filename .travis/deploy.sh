#!/bin/bash
# Decrypt the private key
openssl aes-256-cbc -K $encrypted_42d31b5ecce1_key -iv $encrypted_42d31b5ecce1_iv -in .travis/deploy_key.enc -out ~/.ssh/id_rsa -d
# Set the permission of the key
chmod 600 ~/.ssh/id_rsa
# Start SSH agent
eval $(ssh-agent)
# Add the private key to the system
ssh-add ~/.ssh/id_rsa
# Copy SSH config
cp .travis/ssh_config ~/.ssh/config
# Set Git config
git config --global user.name "BitQiu"
git config --global user.email i@bitqiu.cc
# Clone the repository
git clone git@github.com:bitqiu/bitqiu.github.io.git .deploy_git
# Deploy to GitHub
npm run deploy