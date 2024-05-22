#!/bin/bash

echo "Initiating advanced Ubuntu system maintenance and optimization..."

# Error Handling and Robustness
if [[ $EUID -ne 0 ]]; then
    echo "Error: Insufficient privileges. Please run this script with sudo: 'sudo ./maintain_ubuntu.sh'" >&2
    exit 1
fi

# Detailed Logging and Versioning
script_version="1.3"  # Increment this when making changes
log_file="/var/log/maintain_ubuntu.log"
log_message() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local level="$1"  # INFO, WARNING, ERROR
    shift
    echo "[$timestamp] [$level] [v$script_version] $*" | tee -a "$log_file"
}

# Highly Customizable Options with Explanations
update_kernel=true         # Update to the latest HWE kernel (recommended for newer hardware and better performance)
update_grub=true           # Update GRUB bootloader (essential after kernel updates to ensure proper booting)
send_notification=true    # Send email notification after completion (requires mailutils package)
notification_email="your_email@example.com" # Replace with your actual email address
apt_options="-y --allow-downgrades --allow-remove-essential --allow-change-held-packages" # Comprehensive apt options for maximum flexibility
cleanup_level="aggressive"        # "basic" (remove unused packages), "aggressive" (remove configs, cache), "custom" (specify packages to remove)
custom_cleanup_packages=("libreoffice*" "thunderbird") # Example packages to remove with "custom" cleanup level
additional_packages=("htop" "nmap" "vim")       # Array for installing additional packages (customize as needed)
backup_config=true         # Create backups of configuration files before upgrading packages

# Comprehensive Package List Update with Progress Bar (pv)
log_message "INFO" "Refreshing package information..."
sudo apt update -y | pv -cN "apt update"

# Upgrading Packages with Advanced Options and Conflict Resolution
log_message "INFO" "Upgrading packages with options: $apt_options"
sudo apt upgrade $apt_options | pv -cN "apt upgrade"
if ! sudo apt --fix-broken install $apt_options; then
    log_message "WARNING" "Some broken packages could not be fixed automatically. Please investigate manually."
fi

# Conditional Ubuntu Distribution Upgrade with LTS Handling and Release Notes
if sudo do-release-upgrade -c; then
    new_release=$(lsb_release -a 2>/dev/null | grep "Release:" | awk '{print $2}')
    if [[ $(lsb_release -rs) == *-lts ]]; then
        read -p "New LTS release ($new_release) available. Upgrade now? (y/n): " confirm
        if [[ $confirm == [yY] ]]; then
            log_message "INFO" "Upgrading to LTS release: $new_release"
            sudo do-release-upgrade
        else
            log_message "INFO" "Skipping LTS upgrade as per user choice."
        fi
    else
        log_message "INFO" "Upgrading to the latest non-LTS release: $new_release"
        sudo do-release-upgrade
    fi
else
    log_message "INFO" "No new Ubuntu release available at this time."
fi

# Flexible Package Cleanup Based on Specified Level
log_message "INFO" "Performing $cleanup_level cleanup..."
if [[ $cleanup_level == "basic" ]]; then
    sudo apt autoremove $apt_options | pv -cN "apt autoremove"
elif [[ $cleanup_level == "aggressive" ]]; then
    sudo apt autoremove --purge $apt_options | pv -cN "apt autoremove --purge"
    sudo apt clean
    sudo rm -rf ~/.cache/thumbnails/*
elif [[ $cleanup_level == "custom" ]]; then
    log_message "INFO" "Removing custom packages: ${custom_cleanup_packages[*]}"
    sudo apt remove "${custom_cleanup_packages[@]}" $apt_options
fi

# Intelligent Kernel Update with HWE Prioritization, Reboot Handling, and Backup
if [[ $update_kernel == true ]]; then
    current_kernel=$(uname -r)
    hwe_kernel=$(uname -r | sed 's/-generic//')
    if [[ $current_kernel != $hwe_kernel ]]; then
        log_message "INFO" "Upgrading kernel to latest HWE version..."
        if [[ $backup_config == true ]]; then
            log_message "INFO" "Creating backup of /boot directory..."
            sudo rsync -aAXv --delete /boot /boot.bak
        fi
        sudo apt install --install-recommends linux-generic-hwe-$(lsb_release -rs) $apt_options | pv -cN "apt install kernel"
        if [[ $? -eq 0 ]]; then
            log_message "WARNING" "Kernel updated. Reboot is STRONGLY recommended to apply changes."
            read -p "Reboot now? (y/n): " confirm_reboot
            if [[ $confirm_reboot == [yY] ]]; then
                sudo reboot
            fi
        fi
    else
        log_message "INFO" "Kernel is already using the latest HWE version."
    fi
fi

# GRUB Update with Version Logging and Error Checking
if [[ $update_grub == true ]]; then
    current_grub=$(grub-install -V | head -n 1)
    log_message "INFO" "Updating GRUB bootloader (current version: $current_grub)..."
    if ! sudo update-grub; then
        log_message "ERROR" "GRUB update failed. Please check the logs for details."
    fi
fi

# Installing Additional Packages with Progress Bar
if [[ ${#additional_packages[@]} -gt 0 ]]; then
    log_message "INFO" "Installing additional packages: ${additional_packages[*]}"
    sudo apt install "${additional_packages[@]}" $apt_options | pv -cN "apt install additional"
fi

# Email Notification with Enhanced Formatting, System Info, and Log Attachment
if [[ $send_notification == true ]]; then
    if command -v mail &> /dev/null; then
        log_message "INFO" "Sending email notification to $notification_email..."
        mail -s "Ubuntu System Maintenance Complete" "$notification_email" -A "$log_file" <<EOF
System maintenance and optimization completed at $(date).

Script version: $script_version
Cleanup level: $cleanup_level
Additional packages installed: ${additional_packages[*]}

System information:
$(lsb_release -a)
$(uname -a)

Please review the attached log file for detailed information.
EOF
    else
        log_message "ERROR" "Unable to send email notification. 'mail' command not found."
    fi
fi

# Performance Summary and Completion Message
end_time=$(date +%s)
duration=$((end_time - start_time))
log_message "INFO" "Maintenance completed in $((duration / 60)) minutes and $((duration % 60)) seconds."
