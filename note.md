#!/bin/bash

# Variables - Update with your own values
RESOURCE_GROUP="myResourceGroup"
APP_SERVICE_PLAN="myAppServicePlan"
SUBSCRIPTION_ID="<YourSubscriptionId>"  # Update with your Azure subscription ID
LOCATION="westeurope"  # Location set to West Europe
TARGET_RESOURCE_ID="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/serverfarms/$APP_SERVICE_PLAN"

# Step 1: Set the subscription context
az account set --subscription "$SUBSCRIPTION_ID"

# Step 2: Create Autoscale Setting with default profile
az monitor autoscale create \
  --resource-group "$RESOURCE_GROUP" \
  --name "AppServiceScalingSetting" \
  --resource "$TARGET_RESOURCE_ID" \
  --min-count 2 \
  --max-count 10 \
  --count 2

# Step 3: Add a rule for scaling out based on CPU usage (>70% for 2 minutes)
az monitor autoscale rule create \
  --resource-group "$RESOURCE_GROUP" \
  --autoscale-name "AppServiceScalingSetting" \
  --scale out 1 \
  --condition "Percentage CPU > 70 avg 2m" \
  --cooldown 300 \
  --resource "$TARGET_RESOURCE_ID"

# Step 4: Add a rule for scaling in based on CPU usage (<30% for 5 minutes)
az monitor autoscale rule create \
  --resource-group "$RESOURCE_GROUP" \
  --autoscale-name "AppServiceScalingSetting" \
  --scale in 1 \
  --condition "Percentage CPU < 30 avg 5m" \
  --cooldown 300 \
  --resource "$TARGET_RESOURCE_ID"

# Step 5: Add a recurring schedule for scaling out (scale to 5 instances at 8 AM daily)
az monitor autoscale profile create \
  --resource-group "$RESOURCE_GROUP" \
  --autoscale-name "AppServiceScalingSetting" \
  --name "MorningScaleOutSchedule" \
  --min-count 2 \
  --count 5 \
  --max-count 5 \
  --recurrence week \
  --timezone "W. Europe Standard Time" \
  --start 08:00

# Step 6: Add a recurring schedule for scaling in (scale to 2 instances at 6 PM daily)
az monitor autoscale profile create \
  --resource-group "$RESOURCE_GROUP" \
  --autoscale-name "AppServiceScalingSetting" \
  --name "EveningScaleInSchedule" \
  --min-count 2 \
  --count 2 \
  --max-count 2 \
  --recurrence week \
  --timezone "W. Europe Standard Time" \
  --start 18:00
