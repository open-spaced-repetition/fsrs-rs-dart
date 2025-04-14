#!/bin/bash

# Install required toolchains
rustup target add x86_64-unknown-linux-gnu
rustup target add aarch64-unknown-linux-gnu
rustup target add x86_64-pc-windows-gnu

# Install cross-compilation toolchains
echo "Installing cross-compilation toolchains..."
sudo apt-get update
sudo apt-get install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

# Install Windows toolchain dependencies
if ! command -v x86_64-w64-mingw32-gcc &> /dev/null; then
    echo "Installing mingw-w64..."
    sudo apt-get install -y mingw-w64
fi

# Set up cross-compilation environment variables
export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc
export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_RUNNER="qemu-aarch64 -L /usr/aarch64-linux-gnu"

# Build for Linux targets
echo "Building for Linux targets..."
cargo build --release --target x86_64-unknown-linux-gnu
cargo build --release --target aarch64-unknown-linux-gnu

# Build for Windows targets (GNU only, skipping MSVC due to dart-sys compatibility)
echo "Building for Windows targets..."
cargo build --release --target x86_64-pc-windows-gnu

# Note: Skipping aarch64-pc-windows-msvc due to dart-sys compatibility issues
echo "Note: aarch64-pc-windows-msvc target skipped due to dart-sys compatibility issues"