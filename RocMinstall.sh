#!/bin/bash

set -e

script_directory=$(pwd)

echo "This is a little installer for AMD Compute Library on Cuerdos Linux."
echo "It will enable Blender render through AMD HIP on IA capable system."

echo "Special thanks to https://gitlab.com/gee-one/debian-12-rocm"

# Provide options for user
echo "Please select an option:"
echo "(1) Install system dependencies and ROCM"
echo "(2) Post Install"
echo "(3) Exit"
read -p "Enter your choice: " choice

# Define the valid options and associated function names
actions=(Install_system_Rocm post_install_menu exit)

# Check if the user input is valid
if [[ ! ${actions[$choice-1]} ]]; then
  echo "Invalid choice. Please try again."
  exit 1
fi

# Define packages array and check if Fakelibpython.sh && ROCM_Repos exists
packages=("build-essential" "linux-source" "bc" "kmod" "cpio" "flex" "libncurses5-dev" "libelf-dev" "libssl-dev" "dwarves" "bison" "rsync" "debhelper" "equivs" "sudo" "wget" "gnupg2" "libnuma-dev" "clinfo")
if [ ! -f "Fakelibpython.sh" ]; then
  echo "Error: Fakelibpython.sh needs to be located with RocMinstall.sh in the same folder"
  exit 1
fi
if [ ! -f "ROCM_Repos.sh" ]; then
  echo "Error: ROCM_Repos.sh needs to be located with RocMinstall.sh in the same folder"
  exit 1
fi

Install_system_Rocm(){
  # Install system dependencies
  echo "Installing system dependencies..."
  for package in "${packages[@]}"; do
    if ! dpkg -s "$package" >/dev/null 2>&1; then
      echo "Installing $package..."
      if ! sudo apt install -y "$package"; then
        echo "Error: Failed to install $package"
        exit 1
      fi
    else
      echo "$package is already installed"
    fi
  done

  # Create build directory
  sudo mkdir -p /opt/rocmbuild/
  cd /opt/rocmbuild/

  # Execute scripts for Python and ROCm repos setup
  "$script_directory/Fakelibpython.sh"
  "$script_directory/ROCM_Repos.sh"
  
  echo "Installation ends. Reboot the system in 15 seconds..."

  sleep 15

  # Reboot prompt
  read -n 1 -r -p "Reboot now? (y/n): " REBOOT_NOW
  if [[ $REBOOT_NOW == 'y' ]]; then
    sudo reboot
  else
    echo "No reboot. Installation complete."
  fi
}

post_install_menu() {
  echo "Post-installation actions:"

  # Add ROCm paths to library config
  sudo tee /etc/ld.so.conf.d/rocm.conf > /dev/null <<EOF
/opt/rocm/lib
/opt/rocm/lib64
EOF

  # Add user to video group for ROCm
  sudo usermod -aG video $USER

  # Reload dynamic linker
  sudo ldconfig

  # Update PATH for ROCm binaries
  export PATH=$PATH:/opt/rocm/bin

  # ROCm packages to install
  rocm_packages=("rocm-opencl" "rocm-opencl-dev" "rocminfo" "rocm-utils" "rocm-smi" "rocm-smi-lib" "rocm-opencl-sdk" "rocm-ml-sdk" "rocm-ml-libraries" "rocm-llvm" "rocm-libs" "rocm-hip-sdk" "rocm-hip-runtime-dev" "rocm-hip-runtime" "rocm-hip-libraries" "rocm-gdb" "rocm-device-libs" "rocm-dev" "rocm-debug-agent" "rocm-dbgapi" "rocm-cmake" "miopen-hip")

  echo "Installing ROCm packages..."
  for rocm_package in "${rocm_packages[@]}"; do
    if ! dpkg -s "$rocm_package" >/dev/null 2>&1; then
      echo "Installing $rocm_package..."
      if ! sudo apt install -y "$rocm_package"; then
        echo "Error: Failed to install $rocm_package"
        exit 1
      fi
    else
      echo "$rocm_package is already installed"
    fi
  done
  sudo usermod -aG render $(whoami)
  echo 'SUBSYSTEM=="kfd", KERNEL=="kfd", TAG+="uaccess", TAG+="seat"' | sudo tee /etc/udev/rules.d/70-kfd.rules 
  sudo udevadm control --reload-rules
  sudo udevadm trigger
}

# Execute the selected action
${actions[$choice-1]}
