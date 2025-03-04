#!/usr/bin/env bash

# Color output functions
function echo_info() {
  echo -e "\033[34m[INFO]\033[0m $1"
}

function echo_success() {
  echo -e "\033[32m[SUCCESS]\033[0m $1"
}

function echo_error() {
  echo -e "\033[31m[ERROR]\033[0m $1"
}

# Check if a command exists
function command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# -------------------------------
# 1. Install Homebrew if missing
# -------------------------------
echo_info "Checking for Homebrew..."
if command_exists brew; then
  echo_success "Homebrew is already installed."
else
  echo_info "Homebrew is not installed. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if command_exists brew; then
    echo_success "Homebrew installed successfully."
  else
    echo_error "Homebrew installation failed. Exiting."
    exit 1
  fi
fi

# --------------------------------------
# 2. Install required prerequisites
# --------------------------------------
PREREQS=(git direnv fzf awscli gh)
for pkg in "${PREREQS[@]}"; do
  echo_info "Checking for $pkg..."
  if brew list "$pkg" &>/dev/null; then
    echo_success "$pkg is already installed."
  else
    echo_info "$pkg is not installed. Installing $pkg..."
    brew install "$pkg"
    if brew list "$pkg" &>/dev/null; then
      echo_success "$pkg installed successfully."
    else
      echo_error "Installation of $pkg failed."
    fi
  fi
done

# -------------------------
# 3. Install Terraform
# -------------------------
echo_info "Checking for Terraform..."
if command_exists terraform; then
  echo_success "Terraform is already installed."
else
  echo_info "Terraform is not installed. Installing Terraform..."
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
  brew update
  if command_exists terraform; then
    echo_success "Terraform installed successfully."
  else
    echo_error "Terraform installation failed."
  fi
fi

# -----------------------------------------------------
# 4. Setup direnv in your shell (for zsh configuration)
# -----------------------------------------------------
echo_info "Backing up your ~/.zshrc file to ~/.zshrc_terraform_backup"
cp -f $HOME/.zshrc $HOME/.zshrc_terraform_backup
echo_info "Configuring direnv in your ~/.zshrc..."
if grep -q 'direnv hook zsh' ~/.zshrc; then
  echo_success "direnv is already configured in ~/.zshrc."
else
  echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
  echo_success "direnv configuration added to ~/.zshrc."
fi

# Reload ~/.zshrc only if running in zsh; otherwise prompt the user
#current_shell=$(ps -p $$ -o comm=)

#echo $current_shell
#if [[ "$(ps -p $$ -o comm=)" == "zsh" ]]; then
#  echo_info "Loading a new shell to pickup the changes ~/.zshrc..."
#  exec /bin/zsh
#  echo_success "~/.zshrc reloaded."
#else
#fi

# ---------------------------
# 5. Check installed versions
# ---------------------------
echo_info "Checking installed versions..."
echo -n "Git version: " && git --version
echo -n "direnv version: " && direnv --version
echo -n "fzf version: " && fzf --version
echo -n "Terraform version: " && terraform -v
echo -n "awscli version: " && aws --version

echo_info "Please run the command:\n\tsource ~/.zshrc\nor restart your shell to apply direnv configuration."
echo_success "Installation and configuration completed."
