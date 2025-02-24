#!/usr/bin/env bash
# This script will install several items for a local Terraform development environment
# in Windows: git, direnv, fzf, gnupg, software-properties-common, awscli

set -e  # Exit on error

echo "============================================="
echo "Step 1: Running System Updates (this may take a few minutes)"
echo "============================================="
if sudo apt update -y && sudo apt upgrade -y; then
    echo "✅ System updated successfully!"
else
    echo "❌ System update failed!" >&2
    exit 1
fi

echo "============================================="
echo "Step 2: Installing Development Tools (git, direnv, fzf)"
echo "============================================="
for pkg in git direnv fzf; do
    if which "$pkg" &>/dev/null || whereis "$pkg" | grep -q '/'; then
        echo "✅ $pkg is already installed, skipping..."
    else
        if sudo apt install "$pkg" -y; then
            echo "✅ Installed $pkg successfully!"
        else
            echo "❌ Failed to install $pkg!" >&2
            exit 1
        fi
    fi
done

echo "============================================="
echo "Step 3: Installing Terraform Dependencies"
echo "============================================="
for pkg in gnupg software-properties-common; do
    if which "$pkg" &>/dev/null || whereis "$pkg" | grep -q '/'; then
        echo "✅ $pkg is already installed, skipping..."
    else
        if sudo apt install "$pkg" -y; then
            echo "✅ Installed $pkg successfully!"
        else
            echo "❌ Failed to install $pkg!" >&2
            exit 1
        fi
    fi
done

echo "============================================="
echo "Step 4: Adding HashiCorp GPG Key for Terraform"
echo "============================================="
if [ ! -f "/usr/share/keyrings/hashicorp-archive-keyring.gpg" ]; then
    if wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg; then
        echo "✅ HashiCorp GPG key added!"
    else
        echo "❌ Failed to add HashiCorp GPG key!" >&2
        exit 1
    fi
else
    echo "✅ HashiCorp GPG key already exists, skipping..."
fi

echo "============================================="
echo "Step 5: Adding Terraform Repository"
echo "============================================="
if [ ! -f "/etc/apt/sources.list.d/hashicorp.list" ]; then
    if echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list; then
        echo "✅ Terraform repository added!"
    else
        echo "❌ Failed to add Terraform repository!" >&2
        exit 1
    fi
else
    echo "✅ Terraform repository already exists, skipping..."
fi

echo "============================================="
echo "Step 6: Installing Terraform"
echo "============================================="
if which terraform &>/dev/null || whereis terraform | grep -q '/'; then
    echo "✅ Terraform is already installed, skipping..."
else
    if sudo apt update -y && sudo apt install terraform -y; then
        echo "✅ Terraform installed successfully!"
    else
        echo "❌ Failed to install Terraform!" >&2
        exit 1
    fi
fi

echo "============================================="
echo "Step 7: Installing AWS CLI"
echo "============================================="

# Ensure unzip is installed
if ! which unzip &>/dev/null; then
    echo "Installing unzip..."
    sudo apt install unzip -y
fi

if which aws &>/dev/null; then
    echo "✅ AWS CLI is already installed, skipping..."
else
    echo "Downloading AWS CLI..."
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

    echo "Extracting AWS CLI..."
    unzip -q awscliv2.zip

    echo "Installing AWS CLI..."
    sudo ./aws/install

    echo "Cleaning up..."
    rm -rf awscliv2.zip aws

    echo "✅ AWS CLI installed successfully!"
fi

echo "============================================="
echo "Step 8: Configuring direnv in Bash"
echo "============================================="
if grep -q 'eval "$(direnv hook bash)"' ~/.bashrc; then
    echo "✅ direnv hook already exists in .bashrc, skipping..."
else
    if echo 'eval "$(direnv hook bash)"' >> ~/.bashrc; then
        echo "✅ direnv hook added to .bashrc!"
    else
        echo "❌ Failed to update .bashrc for direnv!" >&2
        exit 1
    fi
fi

echo "============================================="
echo "Step 9: Reloading Shell Configuration"
echo "============================================="
if source ~/.bashrc; then
    echo "✅ Shell reloaded successfully!"
else
    echo "❌ Failed to reload shell!" >&2
    exit 1
fi

echo "============================================="
echo "Step 10: Verifying Installations"
echo "============================================="
for cmd in terraform git direnv fzf aws; do
    if which "$cmd" &>/dev/null || whereis "$cmd" | grep -q '/'; then
        echo "✅ $cmd installed correctly!"
    else
        echo "❌ $cmd installation verification failed!" >&2
        exit 1
    fi
done

echo "🎉 All installations completed successfully!"
