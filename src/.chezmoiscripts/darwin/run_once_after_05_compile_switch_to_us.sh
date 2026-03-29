#!/usr/bin/env bash

set -euo pipefail

mkdir -p ~/.local/bin

cat > /tmp/switch-to-us.swift << 'EOF'
import Carbon
let filter = [kTISPropertyInputSourceID: "com.apple.keylayout.US"] as CFDictionary
if let sources = TISCreateInputSourceList(filter, false)?.takeRetainedValue() as? [TISInputSource],
   let source = sources.first {
    TISSelectInputSource(source)
}
EOF

swiftc /tmp/switch-to-us.swift -o ~/.local/bin/switch-to-us
rm /tmp/switch-to-us.swift
echo "Compiled switch-to-us binary"
