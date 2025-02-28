#!/bin/bash

# Variables (replace these with your values)
RESOURCE_GROUP="my-resource-group"
STORAGE_ACCOUNT="mystaticstorage"
FILE_PATH="./testfile.bin"  # Your 20 MB file
BLOB_NAME="testfile.bin"    # Name in $web container
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Step 1: Enable Defender for Storage
echo "Enabling Microsoft Defender for Storage..."
az rest --method PUT \
  --uri "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT/providers/Microsoft.Security/advancedThreatProtectionSettings/current?api-version=2019-01-01" \
  --body '{"properties": {"isEnabled": true}}' \
  --headers "Content-Type=application/json"

# Wait for Defender to activate (adjust based on observed delay)
echo "Waiting 2 minutes for Defender to activate..."
sleep 120  # 2 minutes; may need 5–10 minutes in practice

# Step 2: Upload the file to $web container
echo "Uploading $FILE_PATH to $web container..."
az storage blob upload \
  --account-name $STORAGE_ACCOUNT \
  --container-name '$web' \
  --file $FILE_PATH \
  --name $BLOB_NAME \
  --overwrite

# Step 3: Wait for scan (give it time to process 20 MB)
echo "Waiting 1 minute for malware scan to complete..."
sleep 60  # Adjust if needed; scans are typically fast for 20 MB

# Step 4: Check for alerts (optional validation)
echo "Checking for malware alerts..."
ALERTS=$(az rest --method GET \
  --uri "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Security/alerts?api-version=2021-01-01" \
  --query "value[?properties.entity.resourceDetails.resourceType=='StorageAccount' && properties.entity.resourceDetails.resourceName=='$STORAGE_ACCOUNT'].{name:properties.alertDisplayName, status:properties.status}" -o json)

if [[ -z "$ALERTS" || "$ALERTS" == "[]" ]]; then
  echo "No alerts found; file likely clean."
else
  echo "Alerts detected: $ALERTS"
fi

# Step 5: Disable Defender for Storage
echo "Disabling Microsoft Defender for Storage..."
az rest --method PUT \
  --uri "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT/providers/Microsoft.Security/advancedThreatProtectionSettings/current?api-version=2019-01-01" \
  --body '{"properties": {"isEnabled": false}}' \
  --headers "Content-Type=application/json"

echo "PoC complete!"
