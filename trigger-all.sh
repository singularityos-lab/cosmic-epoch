#!/bin/bash
for f in .github/workflows/*.yaml .github/workflows/*.yml; do
    ts=$(date +"%Y-%m-%d %H:%M:%S")
    tmp=$(mktemp)
    printf "# Updated at: %s\n\n" "$ts" > "$tmp"
    cat "$f" >> "$tmp"
    mv "$tmp" "$f"
done

