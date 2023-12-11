- script: |
    alertRuleIds=$(echo $(bicepOutputs) | jq -r '.createdAlertRuleIds.value | join(",")')
    echo "##vso[task.setvariable variable=createdAlertRuleIds]$alertRuleIds"
  displayName: 'Convert Array to String and Set as Variable'


- powershell: |
    $bicepOutputs = "$(bicepOutputs)" | ConvertFrom-Json
    $createdAlertRuleIds = $bicepOutputs.createdAlertRuleIds.value -join ','
    echo "##vso[task.setvariable variable=createdAlertRuleIds]$createdAlertRuleIds"
  displayName: 'Convert Array to String and Set as Variable'
