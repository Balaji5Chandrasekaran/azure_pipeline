# Step 1: Get the latest commit message
$commitMessage = git log -1 --pretty=%B
Write-Host "Commit Message: $commitMessage"

# Step 2: Extract the Task ID from the commit message
# Assuming the commit message follows the pattern '#<task number>'
if ($commitMessage -match '#(\d+)') {
    $taskId = $matches[1]  # Extract the numeric Task ID
    Write-Host "Found Task ID: $taskId"
} else {
    Write-Host "Error: No valid Task ID found in the commit message. Please commit with a valid '#<task number>' format."
    exit 1  # Fail the pipeline if no Task ID is found or incorrect format is used
}

# Step 3: Validate the Task state using Azure DevOps API
# Replace with your organization, project, and PAT (personal access token)
$organization = "kloudping"
$project = "DevOps-Team"
$pat = "4k7ubtsg3b23yhywijt7z4czcfhq5gpzekapatn26ujjm6oijzuq"

# Create the Basic Authorization header
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))
$headers = @{
    Authorization = ("Basic {0}" -f $base64AuthInfo)
    "Content-Type" = "application/json"
}

# Azure DevOps REST API endpoint to get the work item details
$workItemUrl = "https://dev.azure.com/$organization/$project/_apis/wit/workitems/$taskId?api-version=7.0"

# Send request to get the work item details
$response = Invoke-RestMethod -Uri $workItemUrl -Headers $headers -Method Get

# Extract the work item state
$workItemState = $response.fields.'System.State'

# Step 4: Validate work item state
if ($workItemState -ne "Done") {
    Write-Host "Work item is not in 'Done' state. Current state: $workItemState"
    exit 1  # Fail the pipeline if work item is not in 'Done' state
} else {
    Write-Host "Work item is in 'Done' state. Proceeding with pipeline..."
}
