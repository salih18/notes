# Running Application Insights Java Locally for Spring Boot Applications

## Introduction

This document provides a comprehensive guide on how to configure and run Application Insights for Java applications locally. This is particularly useful for developers who want to test and debug telemetry data collection in their Spring Boot applications before deploying to a production environment on Azure.

## Prerequisites

Before setting up Application Insights locally, ensure that you have the following:

- A Java-based application (Spring Boot recommended).
- Maven or Gradle for dependency management.
- Internet connection for downloading necessary dependencies.
- Application Insights instrumentation key from your Azure portal.

## Step 1: Add Application Insights Dependency

Start by adding the Application Insights dependency to your `pom.xml` if you're using Maven:

```xml
<dependency>
    <groupId>com.microsoft.azure</groupId>
    <artifactId>applicationinsights-core</artifactId>
    <version>3.5.4</version> <!-- Replace with the latest version -->
</dependency>
```

For Gradle, add the following to your `build.gradle` file:

```groovy
implementation 'com.microsoft.azure:applicationinsights-core:3.5.4' // Replace with the latest version
```

## Step 2: Download the Application Insights Agent

Download the `applicationinsights-agent-<version>.jar` file:

- Visit the [GitHub Releases page for Application Insights Java](https://github.com/microsoft/ApplicationInsights-Java/releases).
- Download the latest version of the agent JAR file.

Alternatively, you can retrieve the JAR from your local Maven repository after including the dependency.

## Step 3: Create the `applicationinsights.json` Configuration File

Create an `applicationinsights.json` file in your `src/main/resources` directory (or where your JAR file resides).

### Example Configuration:

```json
{
  "connectionString": "InstrumentationKey=your-instrumentation-key",
  "sampling": {
    "percentage": 100
  },
  "preview": {
    "captureHttpServerHeaders": {
      "requestHeaders": ["My-Header-A"],
      "responseHeaders": ["My-Header-B"]
    }
  },
  "selfDiagnostics": {
    "destination": "file+console",
    "level": "DEBUG",
    "file": {
      "path": "applicationinsights.log",
      "maxSizeMb": 5,
      "maxHistory": 1
    }
  }
}
```

- **`connectionString`**: Replace with your actual Application Insights instrumentation key.
- **`sampling`**: Set to `100%` to capture all telemetry for testing.
- **`selfDiagnostics`**: Enables detailed logging for both console and file outputs.

## Step 4: Configure the Application

To run your Spring Boot application with Application Insights, use the following command:

```bash
java -javaagent:path/to/applicationinsights-agent-<version>.jar -Dapplicationinsights.configuration.file=src/main/resources/applicationinsights.json -jar target/your-application.jar
```

### Key Points:

- **`-javaagent`**: Points to the Application Insights agent JAR file.
- **`-Dapplicationinsights.configuration.file`**: Specifies the path to your `applicationinsights.json` file.

## Step 5: Run and Test Your Application

Run your application using the above command. As your application processes requests and handles data, Application Insights will collect telemetry data.

### Debugging and Logs:

- **Console Output**: With `selfDiagnostics` set to `DEBUG` and `destination` set to `file+console`, telemetry data and detailed debug logs will be printed to your console.
- **Log File**: A file named `applicationinsights.log` will be created in your specified directory, containing detailed logs.

## Step 6: Verifying Telemetry Data

### Using Logs:

Check the console output or `applicationinsights.log` to see the telemetry data that is being sent to Application Insights. This includes request telemetry, exceptions, custom events, dependencies, and more.

### Using Fiddler or Wireshark:

Alternatively, use tools like Fiddler or Wireshark to capture and inspect the HTTP traffic being sent to Application Insights:

- **Fiddler**: Set up Fiddler to capture HTTPS traffic and filter by Application Insights endpoints.
- **Wireshark**: Capture traffic and filter HTTP requests to inspect telemetry payloads.

## Best Practices

- **Environment Variables**: Use environment variables like `APPLICATIONINSIGHTS_CONNECTION_STRING` to override settings dynamically without changing the JSON configuration.
- **Performance Considerations**: Be mindful of the performance impact when setting `sampling` to 100% in a production environment.

## Conclusion

By following this guide, you can effectively simulate and test Application Insights telemetry data collection for your Spring Boot applications locally. This setup allows you to debug and optimize your telemetry configurations before deploying your application to Azure, ensuring a smoother and more reliable monitoring experience.

## Resources

- [Application Insights for Java on GitHub](https://github.com/microsoft/ApplicationInsights-Java)
- [Azure Monitor Application Insights Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/app/java-in-process-agent)