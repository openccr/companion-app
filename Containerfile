# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2026 openCCR contributors
#
# OCI build image: Flutter 3.35.5 + Android SDK 34 + Linux desktop deps
# Build: podman build -t openccr-companion-build .
# Run:   podman run --rm -v .:/workspace:Z openccr-companion-build flutter build apk

FROM ubuntu:24.04

ARG FLUTTER_VERSION=3.35.5
ARG ANDROID_CMDTOOLS_VERSION=11076708
ARG ANDROID_PLATFORM_VERSION=34
ARG ANDROID_BUILD_TOOLS_VERSION=34.0.0

ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_HOME=/opt/android-sdk \
    FLUTTER_HOME=/opt/flutter \
    PATH="/opt/flutter/bin:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:${PATH}"

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-17-jdk \
    # Linux desktop build deps
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    libstdc++-12-dev \
    && rm -rf /var/lib/apt/lists/*

# Android SDK — cmdline-tools
RUN mkdir -p "${ANDROID_HOME}/cmdline-tools" && \
    curl -fsSL \
      "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDTOOLS_VERSION}_latest.zip" \
      -o /tmp/cmdtools.zip && \
    unzip -q /tmp/cmdtools.zip -d "${ANDROID_HOME}/cmdline-tools" && \
    mv "${ANDROID_HOME}/cmdline-tools/cmdline-tools" "${ANDROID_HOME}/cmdline-tools/latest" && \
    rm /tmp/cmdtools.zip

# Accept SDK licences and install platform packages
RUN yes | sdkmanager --licenses && \
    sdkmanager \
      "platforms;android-${ANDROID_PLATFORM_VERSION}" \
      "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
      "platform-tools"

# Flutter SDK
RUN curl -fsSL \
      "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
      -o /tmp/flutter.tar.xz && \
    tar -xJf /tmp/flutter.tar.xz -C /opt && \
    rm /tmp/flutter.tar.xz

# Create non-root builder user and hand off Flutter + SDK ownership
RUN useradd -m -u 1001 builder && \
    chown -R builder:builder "${FLUTTER_HOME}" "${ANDROID_HOME}"

USER builder

# Configure Flutter and precache as builder user (avoids git dubious-ownership errors)
RUN git config --global --add safe.directory "${FLUTTER_HOME}" && \
    flutter config --no-analytics && \
    flutter config --android-sdk "${ANDROID_HOME}" && \
    flutter precache --android --linux

WORKDIR /workspace

CMD ["flutter", "--version"]
