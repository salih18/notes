# azure-pipelines.yml
# This pipeline:
# 1. Uses a dedicated .temp directory for Vitest temporary files.
# 2. Cleans the .temp directory before running tests.
# 3. Configures Vitest max workers (threads) in vitest.config.ts.
# 4. (Optional) Includes a debugging step using `handle.exe` to identify file locks if an error occurs.

trigger:
  - main

pool:
  vmImage: 'windows-latest'

steps:
  # Step 1: Prepare the dedicated temp directory.
  - script: |
      IF NOT EXIST "$(Build.SourcesDirectory)\.temp" (
        mkdir $(Build.SourcesDirectory)\.temp
      )
      del /F /Q "$(Build.SourcesDirectory)\.temp\*"
    displayName: "Clean and prepare dedicated temp directory"

  # Step 2: Set environment variables for the temp directory (optional if already set in vitest.config.ts).
  - script: |
      echo "##vso[task.setvariable variable=TMPDIR]$(Build.SourcesDirectory)\\.temp"
      echo "##vso[task.setvariable variable=TEMP]$(Build.SourcesDirectory)\\.temp"
      echo "##vso[task.setvariable variable=TMP]$(Build.SourcesDirectory)\\.temp"
    displayName: "Set environment variables for temp directories"
  
  # Step 3: Install dependencies and run tests.
  # Vitest threads are set via vitest.config.ts (e.g., threads: 1), so no need for --max-workers here.
  - script: |
      npm install
      npm run ci-test-unit
    env:
      TMPDIR: "$(Build.SourcesDirectory)\\.temp"
      TEMP: "$(Build.SourcesDirectory)\\.temp"
      TMP: "$(Build.SourcesDirectory)\\.temp"
    displayName: "Run Vitest tests with config-defined single thread"
    continueOnError: true   # Allow pipeline to continue even if tests fail, so we can run the debugging step below.

  # Step 4 (Optional Debugging Step):
  # Use `handle.exe` to identify file locks in .temp if tests fail.
  # This requires `handle.exe` in PATH on a self-hosted agent.
  # If using a Microsoft-hosted agent, consider other debugging methods.
  - script: |
      IF EXIST "C:\Path\To\handle.exe" (
        "C:\Path\To\handle.exe" -u "$(Build.SourcesDirectory)\.temp" > "$(Build.ArtifactStagingDirectory)\handle-output.txt"
      ) ELSE (
        echo handle.exe not found on this agent. Skipping lock debugging.
      )
    condition: failed() # Only run this step if previous steps (like tests) failed
    displayName: "Identify file-locking processes with handle.exe"
  
  # Step 5: Publish the handle-output.txt file as a pipeline artifact for review.
  - task: PublishBuildArtifacts@1
    condition: always() # Always publish even if steps fail, so you can inspect the output after build
    inputs:
      PathtoPublish: "$(Build.ArtifactStagingDirectory)"
      ArtifactName: "debug-logs"
    displayName: "Publish debug logs"



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
