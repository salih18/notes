steps:
- script: |
    echo "Setting a custom temporary directory..."
    set TMP=./custom-temp
    set TEMP=./custom-temp
    mkdir custom-temp
  displayName: "Set Custom Temporary Directory"

- script: |
    echo "Running Vitest tests..."
    vitest --run
  displayName: "Run Vitest Tests"

- script: |
    echo "Cleaning up the custom temporary directory..."
    rmdir /s /q custom-temp
  displayName: "Clean Up Custom Temp Directory"
