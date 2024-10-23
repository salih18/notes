#!/bin/bash

# Variables - Update with your own values
RESOURCE_GROUP="myResourceGroup"
APP_SERVICE_PLAN="myAppServicePlan"
WEB_APP_NAME="myWebApp"
LOCATION="EastUS"  # Adjust this based on your region

# Step 1: Create Autoscale Profile (e.g., 'Default' profile with 2 to 10 instances)
az monitor autoscale create \
  --resource-group $RESOURCE_GROUP \
  --resource "/subscriptions/<SubscriptionId>/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/serverfarms/$APP_SERVICE_PLAN" \
  --name "AppServiceScalingProfile" \
  --min-count 2 \
  --max-count 10 \
  --count 2 \
  --location $LOCATION

# Step 2: Add a rule for scaling out based on CPU usage (>70% for 2 minutes)
az monitor autoscale rule create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name "AppServiceScalingProfile" \
  --condition "Percentage CPU > 70 avg 2m" \
  --scale out 1 \
  --cooldown 300  # 5 minutes cooldown period

# Step 3: Add a rule for scaling in based on CPU usage (<30% for 5 minutes)
az monitor autoscale rule create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name "AppServiceScalingProfile" \
  --condition "Percentage CPU < 30 avg 5m" \
  --scale in 1 \
  --cooldown 300  # 5 minutes cooldown period

# Step 4: Add a rule for scaling out based on Memory usage (>80% for 2 minutes)
az monitor autoscale rule create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name "AppServiceScalingProfile" \
  --condition "Memory > 80 avg 2m" \
  --scale out 1 \
  --cooldown 300  # 5 minutes cooldown period

# Step 5: Add a rule for scaling in based on Memory usage (<50% for 5 minutes)
az monitor autoscale rule create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name "AppServiceScalingProfile" \
  --condition "Memory < 50 avg 5m" \
  --scale in 1 \
  --cooldown 300  # 5 minutes cooldown period

# Step 6: Add a Schedule for Scaling Out (e.g., Scale out to 5 instances at 8 AM every day)
az monitor autoscale profile create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name "AppServiceScalingProfile" \
  --name "MorningScaleOutSchedule" \
  --timezone "UTC" \
  --recurrence week Sun Mon Tue Wed Thu Fri Sat \
  --start 08:00 \
  --end 08:30 \
  --min-count 2 \
  --max-count 5 \
  --count 5

# Step 7: Add a Schedule for Scaling In (e.g., Scale back to 2 instances at 6 PM every day)
az monitor autoscale profile create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name "AppServiceScalingProfile" \
  --name "EveningScaleInSchedule" \
  --timezone "UTC" \
  --recurrence week Sun Mon Tue Wed Thu Fri Sat \
  --start 18:00 \
  --end 18:30 \
  --min-count 2 \
  --max-count 2 \
  --count 2
