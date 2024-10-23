#!/bin/bash

# Variables - Update with your own values
RESOURCE_GROUP="myResourceGroup"
APP_SERVICE_PLAN="myAppServicePlan"
SUBSCRIPTION_ID="<YourSubscriptionId>"  # Update with your Azure subscription ID
LOCATION="westeurope"  # Location set to West Europe

# Step 1: Set the subscription context
az account set --subscription $SUBSCRIPTION_ID

# Step 2: Create Autoscale Profile (e.g., 'Default' profile with 2 to 10 instances)
az monitor autoscale create \
  --resource-group $RESOURCE_GROUP \
  --resource "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/serverfarms/$APP_SERVICE_PLAN" \
  --name "AppServiceScalingProfile" \
  --min-count 2 \
  --max-count 10 \
  --count 2 \
  --location $LOCATION

# Step 3: Add a rule for scaling out based on CPU usage (>70% for 2 minutes)
az monitor autoscale rule create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name "AppServiceScalingProfile" \
  --condition "Percentage CPU > 70 avg 2m" \
  --scale "+1" \
  --cooldown 300  # 5 minutes cooldown period

# Step 4: Add a rule for scaling in based on CPU usage (<30% for 5 minutes)
az monitor autoscale rule create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name "AppServiceScalingProfile" \
  --condition "Percentage CPU < 30 avg 5m" \
  --scale "-1" \
  --cooldown 300  # 5 minutes cooldown period

# Step 5: Add a recurring schedule for scaling out (e.g., scale to 5 instances at 8 AM daily)
az monitor autoscale profile create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name "AppServiceScalingProfile" \
  --name "MorningScaleOutSchedule" \
  --min-count 2 \
  --max-count 5 \
  --count 5 \
  --recurrence "week Sun Mon Tue Wed Thu Fri Sat" \
  --timezone "UTC" \
  --start "08:00" \
  --end "08:30"

# Step 6: Add a recurring schedule for scaling in (e.g., scale to 2 instances at 6 PM daily)
az monitor autoscale profile create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name "AppServiceScalingProfile" \
  --name "EveningScaleInSchedule" \
  --min-count 2 \
  --max-count 2 \
  --count 2 \
  --recurrence "week Sun Mon Tue Wed Thu Fri Sat" \
  --timezone "UTC" \
  --start "18:00" \
  --end "18:30"
