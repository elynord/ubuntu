# Ubuntu Maintenance Script

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This Bash script automates essential maintenance tasks for your Ubuntu system, ensuring it stays up-to-date, secure, and optimized.

## Features

* **Comprehensive Package Management:**
    - Upgrades all installed packages with intelligent conflict resolution.
    - Handles broken packages and attempts automatic fixes.
    - Offers flexible cleanup options, from basic to aggressive, including custom package removal.
    - Installs additional packages based on your preferences.
* **Kernel and Bootloader Management:**
    - Upgrades to the latest HWE kernel for improved hardware compatibility and performance.
    - Backs up the `/boot` directory before kernel updates for safety.
    - Updates the GRUB bootloader to ensure proper booting after kernel changes.
* **Ubuntu Distribution Upgrade:**
    - Checks for and performs distribution upgrades, with special handling for LTS releases.
    - Prompts for confirmation before upgrading to a new LTS release.
* **Enhanced User Experience:**
    - Provides progress bars for long-running tasks.
    - Logs all actions to a file for easy review and troubleshooting.
    - Sends an email notification upon completion with detailed system information and the attached log file.
* **Customization and Flexibility:**
    - Easily configure options like kernel updates, cleanup level, additional packages, and email notifications.
    - Modify the script to suit your specific needs and preferences.

## Usage

1. Clone this repository:

   ```bash
   git clone https://github.com/elynord/ubuntu
   ```

2. Make the script executable:

   ```bash
   chmod +x ubuntu/maintenance.sh
   ```

3. Run the script with sudo:

   ```bash
   sudo ./ubuntu/maintenance.sh
   ```

4. Review the log file at `/var/log/maintain_ubuntu.log` for details.

## Customization

Open the `maintenance.sh` script and modify the following variables to customize its behavior:

* `update_kernel`: Enable/disable kernel updates (default: true)
* `update_grub`: Enable/disable GRUB updates (default: true)
* `send_notification`: Enable/disable email notifications (default: true)
* `notification_email`: Your email address for notifications
* `cleanup_level`: "basic", "aggressive", or "custom" (default: "aggressive")
* `custom_cleanup_packages`: Array of package names to remove if `cleanup_level` is "custom"
* `additional_packages`: Array of package names to install
* `backup_config`: Enable/disable backup of configuration files before upgrades (default: true)

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This script is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
