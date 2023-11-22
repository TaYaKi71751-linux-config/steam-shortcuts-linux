#!/bin/bash

/usr/bin/flatpak "run" "--branch=stable" "--command=/app/bin/obs" "--file-forwarding" "com.obsproject.Studio" "@@u" "@@"
