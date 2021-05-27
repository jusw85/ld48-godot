#!/bin/bash

mkdir -p ../builds/html5
godot --export "HTML5" ../builds/html5/index.html
pushd ../builds/
zip -r builds.zip html5
popd
godot --export "Linux/X11" ../builds/ld48-punch-my-dig.x86_64
godot --export "Windows Desktop" ../builds/ld48-punch-my-dig.exe
