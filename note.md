#!/bin/bash

# Variables - Update with your own values
RESOURCE_GROUP="myResourceGroup"
APP_SERVICE_PLAN="myAppServicePlan"
SUBSCRIPTION_ID="<YourSubscriptionId>"  # Update with your Azure subscription ID
LOCATION="westeurope"  # Location set to West Europe

# Step 1: Set the subscription context
az account set --subscription $SUBSCRIPTION_ID

# Step 2: Create Autoscale Setting with default profile
az monitor autoscale create \
  --resource-group $RESOURCE_GROUP \
  --name "AppServiceScalingSetting" \
  --target "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/serverfarms/$APP_SERVICE_PLAN" \
  --min-count 2 \
  --max-count 10 \
  --count 2

# Step 3: Add a rule for scaling out based on CPU usage (>70% for 2 minutes)
az monitor autoscale rule create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name "AppServiceScalingSetting" \
  --condition "Percentage CPU > 70 avg 2m" \
  --scale out 1 \
  --cooldown 300  # 5 minutes cooldown period

# Step 4: Add a rule for scaling in based on CPU usage (<30% for 5 minutes)
az monitor autoscale rule create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name "AppServiceScalingSetting" \
  --condition "Percentage CPU < 30 avg 5m" \
  --scale in 1 \
  --cooldown 300  # 5 minutes cooldown period

# Step 5: Add a recurring schedule for scaling out (scale to 5 instances at 8 AM daily)
az monitor autoscale profile create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name "AppServiceScalingSetting" \
  --name "MorningScaleOutSchedule" \
  --count 5 \
  --min-count 2 \
  --max-count 5 \
  --recurrence week \
  --timezone "UTC" \
  --days "Sun Mon Tue Wed Thu Fri Sat" \
  --hours 8 \
  --minutes 0

# Step 6: Add a recurring schedule for scaling in (scale to 2 instances at 6 PM daily)
az monitor autoscale profile create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name "AppServiceScalingSetting" \
  --name "EveningScaleInSchedule" \
  --count 2 \
  --min-count 2 \
  --max-count 2 \
  --recurrence week \
  --timezone "UTC" \
  --days "Sun Mon Tue Wed Thu Fri Sat" \
  --hours 18 \
  --minutes 0
