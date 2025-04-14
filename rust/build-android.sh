#!/bin/bash

# Set NDK path - adjust this to your NDK installation path
export NDK_HOME="$HOME/Android/Sdk/ndk/29.0.13113456"
export PATH="$NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"

# Build for all Android targets
cargo build --release --target aarch64-linux-android
cargo build --release --target armv7-linux-androideabi
cargo build --release --target i686-linux-android
cargo build --release --target x86_64-linux-android