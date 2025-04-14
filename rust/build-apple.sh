#!/bin/bash

# Install required toolchains
rustup target add x86_64-apple-darwin
rustup target add aarch64-apple-darwin
rustup target add aarch64-apple-ios
rustup target add x86_64-apple-ios
rustup target add aarch64-apple-ios-sim

# Check for Xcode installation (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! xcode-select -p &> /dev/null; then
        echo "Xcode not found. Please install Xcode from the App Store."
        exit 1
    fi
fi

# Build for macOS targets
cargo build --release --target x86_64-apple-darwin
cargo build --release --target aarch64-apple-darwin

# Build for iOS targets
cargo build --release --target aarch64-apple-ios
cargo build --release --target x86_64-apple-ios
cargo build --release --target aarch64-apple-ios-sim