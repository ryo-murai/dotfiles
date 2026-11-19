#!/bin/sh

find . -type d -exec chmod 755 {} +
find . -type f -exec chmod 644 {} +

find . -type f \( -name 'mvnw' -o -name 'gradlew' -o -name '*.sh' \) -exec chmod +x {} +
