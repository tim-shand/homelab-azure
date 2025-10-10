<#
#======================================#
# Bootstrap: Azure (PowerShell)
#======================================#

# DESCRIPTION:
Bootstrap script to prepare Azure tenant for management via Terraform and Github Actions.
This script performs the following tasks:
- Checks for required local applications (Azure CLI, Terraform, GitHub CLI).
- Validates Azure CLI authentication, uses Azure tenant ID and subscription from current session.
- Validates Github CLI authentication, confirms provided repo name is available.
- Initializes and applies Terraform configuration to create bootstrap resources in Azure.

# USAGE:
.\bootstrap-azure-tf-gh.ps1
.\bootstrap-azure-tf-gh.ps1 -destroy
#>

#=============================================#
# VARIABLES
#=============================================#

# General Settings/Variables.
param(
    [switch]$destroy, # Add switch parameter for delete option.
    [Parameter(Mandatory=$true)][string]$envFile # Local variables file ".\env.psd1".
)
$workingDir = "$((Get-Location).Path)\terraform" # Move working directory to current.

# Required applications.
$requiredApps = @(
    [PSCustomObject]@{ Name = "Azure CLI"; Command = "az" }
    [PSCustomObject]@{ Name = "Terraform"; Command = "terraform" }
    [PSCustomObject]@{ Name = "GitHub CLI"; Command = "gh" }
)

# Determine request action and populate hashtable for logging purposes.
if($destroy){
    $sys_action = @{
        do = "Remove"
        past = "Removed"
        current = "Removing"
        colour = "Magenta"
    }
}
else{
    $sys_action = @{
        do = "Create"
        past = "Created"
        current= "Creating"
        colour = "Green"
    }
}

#=============================================#
# FUNCTIONS
#=============================================#

# Function: Custom logging with terminal colours and timestamp etc.
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("INF", "WRN", "ERR", "SYS")]
        [string]$Level,
        [Parameter(Mandatory=$true)]
        [string]$Message
    )    
    # Set terminal colours based on level parameter.
    switch ($Level){
        "INF" {$textColour = "Green"}
        "WRN" {$textColour = "Yellow"}
        "ERR" {$textColour = "Red"}
        "SYS" {$textColour = "White"}
        default {$textColour = "White"}
    }
    # Write to console.
    if($level -eq "SYS"){
        Write-Host "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) | [$Level] | $message" -ForegroundColor $textColour -NoNewline
    }
    else{
        Write-Host "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) | [$Level] | $message" -ForegroundColor $textColour
    } 
}

# Function: User confirmation prompt, can be re-used for various stages.
function Get-UserConfirm {
    while ($true) {
        $userConfirm = (Read-Host -Prompt "Do you wish to proceed [Y/N]?")
        switch -Regex ($userConfirm.Trim().ToLower()) {
            "^(y|yes)$" {
                return $true
            }
            "^(n|no)$" {
                Write-Log -Level "WRN" -Message "- User declined to proceed."
                return $false
            }
            default {
                Write-Log -Level "WRN" -Message "- Invalid response. Please enter [Y/Yes/N/No]."
            }
        }
    }
}

#=============================================#
# MAIN: Validations & Pre-Checks
#=============================================#

# Clear the console and generate script header message.
Clear-Host
Write-Host -ForegroundColor Cyan "`r`n==========================================================================="
Write-Host -ForegroundColor Magenta "                Bootstrap Script: Azure | Terraform | Github                "
Write-Host -ForegroundColor Cyan "===========================================================================`r`n"
Write-Host -ForegroundColor Cyan "*** Performing Initial Checks & Validations"

# Validate: Local variables file. Use content for populating TFVARS and other settings.
Write-Log -Level "SYS" -Message "Check: Validate local variables file... "
Try{
    $config = Import-PowerShellDataFile -Path $envFile -ErrorAction Stop
    Write-Host "PASS" -ForegroundColor Green
}
Catch{
    Write-Host "FAIL" -ForegroundColor Red
    Write-Log -Level "ERR" -Message "- Failed to import local variables file '$($envFile)'."
    Write-Log -Level "ERR" -Message "- $_"
    exit 1
}

# Validate: Check install status for required applications.
Write-Log -Level "SYS" -Message "Check: Required applications... "
ForEach($app in $requiredApps) {
    Try{
        Get-Command $app.Command > $null 2>&1
    }
    Catch{
        Write-Host "FAIL" -ForegroundColor Red
        Write-Log -Level "ERR" -Message "- Required application '$($app.Name)' is missing. Please install and try again."
        exit 1
    }
} 
Write-Host "PASS" -ForegroundColor Green

# Validate: Github CLI - Authentication. Check for existing authenticated session.
Write-Log -Level "SYS" -Message "Check: Validate Github CLI authenticated session... "
Try{
    $ghSession = gh api user 2>$null | ConvertFrom-JSON
    Write-Host "PASS" -ForegroundColor Green
    Write-Log -Level "INF" -Message "- Github CLI logged in as: $($ghSession.login) [$($ghSession.html_url)]"
} 
Catch{
    Write-Host "FAIL" -ForegroundColor Red
    Write-Log -Level "ERR" -Message "- Failed GitHub CLI authentication check. Please run 'gh auth login' and try again."
    exit 1
}

# Validate: Github CLI - Check if repository exists, and is accessible.
if(-not ($destroy) ){
    $repoCheck = (gh repo list --json name | ConvertFrom-JSON)
    if ($repoCheck | Where-Object {$_.name -eq "$($config.github_config.repo)"} ) {
        Write-Log -Level "INF" -Message "- Repository '$($config.github_config.org)/$($config.github_config.repo)' exists."
    }
    else{
        Write-Log -Level "ERR" -Message "- Provided repository '$($config.github_config.org)/$($config.github_config.repo)' cannot be found. Please check configuration is correct."
        exit 1
    }
}

# Validate: Azure CLI authentication. Check for existing authenticated session.
Write-Log -Level "SYS" -Message "Check: Validate Azure CLI authenticated session... "
$azCheck = $( az account show --only-show-errors )
if(-not ( $azCheck ) ){
    Write-Host "FAIL" -ForegroundColor Red
    Write-Log -Level "ERR" -Message "- Failed Azure CLI authentication check. Please run 'az login' manually and try again."
    exit 1
}
else{
    Write-Host "PASS" -ForegroundColor Green
    $azSession = az account show --only-show-errors 2>&1 | ConvertFrom-JSON
    Write-Log -Level "INF" -Message "- Current User: $($azSession.user.name)"
    Write-Log -Level "INF" -Message "- Azure Tenant: $($azSession.tenantDefaultDomain) [$($azSession.tenantId)]"
    Write-Log -Level "INF" -Message "- Subscription: $($azSession.name) [$($azSession.id)]"
}

#================================================#
# MAIN: Stage 2 - Display Intended Actions
#================================================#

$name_format = "$($config.naming.prefix)-$($config.naming.platform)-$($config.naming.project)-$($config.naming.service)"
$name_format_sa = "$($config.naming.prefix)$($config.naming.platform)$($config.naming.project)$($config.naming.service)"

Write-Host ""
Write-Host "Target Azure Environment:" -ForegroundColor Cyan
Write-Host "- Tenant ID: $($azSession.tenantId)"
Write-Host "- Subscription ID: $($azSession.id)"
Write-Host "- Subscription Name: $($azSession.name)"
Write-Host "- Location: $($config.location)"
Write-Host ""
Write-Host "The following resources will be " -ForegroundColor Cyan -NoNewLine
Write-Host "$(($sys_action.past).ToUpper()):" -ForegroundColor $sys_action.colour

Write-Host "- Github: $($config.github_config.org)/$($config.github_config.repo)" -ForegroundColor Yellow
Write-Host "  - Secrets: Used by workflows for authentication."
Write-Host "  - Variables: Used by workflows for Terraform remote backend."
Write-Host "- Azure: $($azSession.tenantDefaultDomain) [$($azSession.tenantId)]" -ForegroundColor Yellow
Write-Host "  - Core Management Group: $($config.core_management_group_display_name) ($($config.core_management_group_id))"
Write-Host "  - Entra ID Service Principal: $name_format-sp"
if($destroy){
    Write-Host "  - Resource Group: $name_format-rg" -NoNewline
    Write-Host " (** INCLUDES ALL CHILD RESOURCES **)" -ForegroundColor $sys_action.colour
}
else{
    Write-Host "  - Resource Group: $name_format-rg"
    Write-Host "  - Storage Account: $name_format_sa**** [Determined during deployment (requires random integers)]"
    Write-Host "  - Storage Container: $name_format-state"
}
Write-Host ""
Write-Log -Level "WRN" -Message "The above resources will be $(($sys_action.past).ToLower()) in the target environment."
if(-not (Get-UserConfirm) ){
    Write-Log -Level "ERR" -Message "User aborted process. Please confirm intended configuration and try again."
    exit 1
} 

#================================================#
# MAIN: Stage 3 - Prepare Terraform
#================================================#

# Generate TFVARS file.
$tfVARS = @"
# SAFE TO COMMIT
# This file contains only non-sensitive configuration data (no credentials or secrets).
# All secrets are stored securely in Github Secrets or environment variables.

# Azure Settings.
location = "newzealandnorth" # Desired location for resources to be deployed in Azure.
core_management_group_id = "tjs-core-mg" # Desired ID for the top-level management group (under Tenant Root).
core_management_group_display_name = "TShand" # Desired display name for the top-level management group (under Tenant Root).

# Naming Settings (used for resource names).
naming = {
    prefix = "$($config.naming.prefix)" # Short name of organization ("abc").
    platform = "$($config.naming.platform)" # Platform type: ("plz", "app")
    project = "$($config.naming.project)" # Project name for related resources ("platform", "webapp01").
    service = "$($config.naming.service)" # Service name used in the project ("gov", "con", "sec").
    environment = "$($config.naming.environment)" # Environment for resources/project ("dev", "tst", "prd").
}

# Tags (assigned to all bootstrap resources).
tags = {
    Project = "$($config.tags.project)" # Name of the project the resources are for.
    Environment = "$($config.tags.environment)" # dev, tst, prd
    Owner = "$($config.tags.owner)" # Team responsible for the resources.
    Creator = "$($config.tags.creator)" # Person or process that created the resources.
    Modified = "$(Get-Date -f 'yyyyMMdd.HHmmss')" # Last modified timestamp.
    ModifiedBy = "$($config.tags.ModifiedBy)"
}

# Github Settings.
github_config = {
    org = "$($config.github_config.org)" # Github organization where repository is located.
    repo = "$($config.github_config.repo)" # Github repository to use for adding secrets and variables.
    branch = "$($config.github_config.branch)" # Using main branch of repository.
}
"@

# Write out TFVARS file.
$tfVARS | Out-File -Encoding utf8 -FilePath "$workingDir\bootstrap.tfvars" -Force

# Terraform: Initialize
Write-Log -Level "SYS" -Message "Performing Action: Initialize Terraform configuration... "
if(terraform -chdir="$($workingDir)" init -upgrade){
    Write-Host "PASS" -ForegroundColor Green
} else{
    Write-Host "FAIL" -ForegroundColor Red
    Write-Log -Level "ERR" -Message "- Terraform initialization failed. Please check configuration and try again."
    exit 1
}

# Terraform: Validate
Write-Log -Level "SYS" -Message "Performing Action: Running Terraform validation... "
if(terraform -chdir="$($workingDir)" validate){
    Write-Host "PASS" -ForegroundColor Green
} else{
    Write-Host "FAIL" -ForegroundColor Red
    Write-Log -Level "ERR" -Message "- Terraform validation failed. Please check configuration and try again."
    exit 1
}

#===================================================#
# MAIN: Stage 4 - Execute Terraform (Deploy/Destroy)
#===================================================#

if($destroy){
    # Terraform: Destroy
    Write-Log -Level "WRN" -Message "Terraform will now remove all bootstrap resources. This may take several minutes to complete."
    if(-not (Get-UserConfirm) ){
        Write-Log -Level "ERR" -Message "User aborted process. Please confirm intended configuration and try again."
        exit 1
    }
    else{
        Write-Log -Level "SYS" -Message "Performing Action: Running Terraform destroy... "
        if(terraform -chdir="$($workingDir)" destroy --auto-approve `
            -var-file="bootstrap.tfvars" `
            -var="subscription_id=$($azSession.id)"
        ){
            Write-Host "PASS" -ForegroundColor Green
            Write-Host -ForegroundColor Cyan "`r`n*** Bootstrap Removal Complete! ***`r`n"
        } else{
            Write-Host "FAIL" -ForegroundColor Red
            Write-Log -Level "ERR" -Message "- Terraform plan failed. Please check configuration and try again."
            exit 1
        }
    }
}
else{
    # Terraform: Plan
    Write-Log -Level "SYS" -Message "Performing Action: Running Terraform plan... "
    if(terraform -chdir="$($workingDir)" plan --out=bootstrap.tfplan `
            -var-file="bootstrap.tfvars" `
            -var="subscription_id=$($azSession.id)"
    ){
        Write-Host "PASS" -ForegroundColor Green
        terraform -chdir="$($workingDir)" show "$workingDir\bootstrap.tfplan"
    } else{
        Write-Host "FAIL" -ForegroundColor Red
        Write-Log -Level "ERR" -Message "- Terraform plan failed. Please check configuration and try again."
        exit 1
    }

    # Terraform: Apply
    if(Test-Path -Path "$workingDir\bootstrap.tfplan"){
        Write-Host ""
        Write-Log -Level "WRN" -Message "Terraform will now deploy resources. This may take several minutes to complete."
        if(-not (Get-UserConfirm) ){
            Write-Log -Level "ERR" -Message "User aborted process. Please confirm intended configuration and try again."
            exit 1
        }
        else{
            Write-Log -Level "SYS" -Message "Performing Action: Running Terraform apply... "
            if(terraform -chdir="$($workingDir)" apply bootstrap.tfplan){
                Write-Host "PASS" -ForegroundColor Green
            } else{
                Write-Host "FAIL" -ForegroundColor Red
                Write-Log -Level "ERR" -Message "- Terraform plan failed. Please check configuration and try again."
                exit 1
            }
        }
    } else{
        Write-Log -Level "ERR" -Message "- Terraform plan file missing! Please check configuration and try again."
        exit 1  
    }
}

#================================================#
# MAIN: Stage 5 - Migrate State to Azure
#================================================#

if(-not ($destroy)){
    # Get Github variables from Terraform output.
    Write-Log -Level "SYS" -Message "Retrieving Terraform backend details from output... "
    Try{
        $tf_rg = terraform -chdir="$($workingDir)" output -raw tf_backend_rg_name
        $tf_sa = terraform -chdir="$($workingDir)" output -raw tf_backend_sa_name
        $tf_cn = terraform -chdir="$($workingDir)" output -raw tf_backend_cn_name
        Write-Host "PASS" -ForegroundColor Green
    }
    Catch{
        Write-Host "FAIL" -ForegroundColor Red
        Write-Log -Level "ERR" -Message "- Failed to get Terraform output values. Please check configuration and try again."
        exit 1
    }

    # Generate backend config for state migration.
    $tfBackend = `
@"
terraform {
  backend "azurerm" {
    resource_group_name  = "$($tf_rg)"
    storage_account_name = "$($tf_sa)"
    container_name       = "$($tf_cn)"
    key                  = "bootstrap.tfstate"
  }
}
"@
    $tfBackend | Out-File -Encoding utf8 -FilePath "$workingDir\backend.tf" -Force

    # Terraform: Migrate State
    Write-Log -Level "WRN" -Message "Terraform will now migrate state to Azure."
    if(Get-UserConfirm){
        Write-Log -Level "SYS" -Message "Migrating Terraform state to Azure... "
        if(terraform -chdir="$($workingDir)" init -migrate-state -force-copy -input=false){
            Write-Host "PASS" -ForegroundColor Green
        }
        else{
            Write-Host "FAIL" -ForegroundColor Red
            Write-Log -Level "ERR" -Message "- Failed to migrate Terraform state to Azure."
        }
    }
    else{
        Write-Log -Level "WRN" -Message "- Terraform state migration aborted by user."
        exit 1
    }
}

#================================================#
# MAIN: Stage 6 - Clean Up
#================================================#

# Clean Up
Write-Log -Level "SYS" -Message "Running clean up process... "
Try{
    Remove-Item -Path "$workingDir\.terraform" -Recurse -Force
    Remove-Item -Path "$workingDir\.terraform.*" -Force
    Remove-Item -Path "$workingDir\*.tfstate*" -Force
    Remove-Item -Path "$workingDir\*.tfplan*" -Force
    Write-Host "PASS" -ForegroundColor Green
}
Catch{
    Write-Host "FAIL" -ForegroundColor Red
    Write-Log -Level "ERR" -Message "- Failed to clean up all resources. Manual clean up of files may be required."
}

Write-Host -ForegroundColor Cyan "`r`n*** Bootstrap Deployment Complete! ***`r`n"