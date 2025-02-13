# Initialize variables
$LOCATION = ""
$USERNAME = ""
$PREFIX = ""
$SSH_KEY = ""
$PROJECT_ROOT = "../../"  # Navigate up from Script-Pack/Powershell to SkyFall-Pack
$TFVARS_PATH = Join-Path $PROJECT_ROOT "Terraform-Pack/terraform.tfvars"

# Function to check if location is valid
function Check-Location {
    param (
        [string]$location
    )
    
    $location = $location.ToLower()
    
    # Array of valid Azure locations
    $valid_locations = @(
        "eastus",
        "eastus2",
        "westus",
        "westus2",
        "westus3",
        "northeurope",
        "westeurope",
        "southeastasia",
        "eastasia",
        "australiaeast",
        "australiasoutheast",
        "japaneast",
        "japanwest"
    )
    
    # Check if provided location exists in valid_locations
    if ($valid_locations -contains $location) {
        $script:LOCATION = $location
        return $true
    }
    
    Write-Host "`n[!] Error: Invalid Azure location provided`n" -ForegroundColor Red
    Write-Host "[*] Valid locations are:`n" -ForegroundColor Yellow
    $valid_locations | ForEach-Object { Write-Host $_ }
    exit 1
}

# Function to display usage
function Show-Usage {
    Write-Host "Usage: $($MyInvocation.MyCommand.Name) [-l|-location <value>] [-u|-username <value>] [-n|-name <value>] [-s|-ssh <value>]"
    Write-Host "All arguments are mandatory!`n"
    Write-Host "Arguments:"
    Write-Host "  -l, -location    Azure region location"
    Write-Host "  -u, -username    VM username"
    Write-Host "  -n, -name        Resource name prefix"
    Write-Host "  -s, -ssh         SSH key name`n"
    Write-Host "Example with full flags:"
    Write-Host "  $($MyInvocation.MyCommand.Name) -location westus2 -username nickvourd -name my-vm -ssh my-ssh-key`n"
    Write-Host "Example with short flags:"
    Write-Host "  $($MyInvocation.MyCommand.Name) -l westus2 -u nickvourd -n my-vm -s my-ssh-key`n"
    exit 1
}

# Parse command line arguments
$i = 0
while ($i -lt $args.Count) {
    switch ($args[$i]) {
        { $_ -in "-l","-location" } {
            Check-Location $args[$i+1]
            $i += 2
        }
        { $_ -in "-u","-username" } {
            $USERNAME = $args[$i+1]
            $i += 2
        }
        { $_ -in "-n","-name" } {
            $PREFIX = $args[$i+1]
            $i += 2
        }
        { $_ -in "-s","-ssh" } {
            $SSH_KEY = $args[$i+1]
            $i += 2
        }
        default {
            Write-Host "Error: Unknown parameter $($args[$i])" -ForegroundColor Red
            Show-Usage
        }
    }
}

# Check if all required parameters are provided
if (-not $LOCATION -or -not $USERNAME -or -not $PREFIX -or -not $SSH_KEY) {
    Write-Host "Error: All parameters are required!" -ForegroundColor Red
    Show-Usage
}

# Check if Terraform-Pack directory exists
if (-not (Test-Path (Join-Path $PROJECT_ROOT "Terraform-Pack"))) {
    Write-Host "Error: Terraform-Pack directory not found in SkyFall-Pack" -ForegroundColor Red
    exit 1
}

# Check if terraform.tfvars exists in Terraform-Pack
if (-not (Test-Path $TFVARS_PATH)) {
    Write-Host "Error: terraform.tfvars file not found in SkyFall-Pack/Terraform-Pack directory" -ForegroundColor Red
    exit 1
}

# Create the content for terraform.tfvars
$content = @"
resource_group_location = "$LOCATION"
username               = "$USERNAME"
prefix                 = "$PREFIX"
ssh_privkey           = "$SSH_KEY"
"@

# Write content to terraform.tfvars
Set-Content -Path $TFVARS_PATH -Value $content

Write-Host "`n[+] terraform.tfvars in SkyFall-Pack/Terraform-Pack has been updated with:`n" -ForegroundColor Green
Write-Host "VM-Location: $LOCATION"
Write-Host "Username: $USERNAME"
Write-Host "Resource Prefix: $PREFIX"
Write-Host "SSH Key Name: $SSH_KEY`n"