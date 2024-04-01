# Array of environments to deploy to
$ENVIRONMENTS = @(
    "PROD",
    "DEV"
    )
$ACTIONS = @(
    "APPLY TERRAFORM"
    )

# Supporting functions
function Select-Option {
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$Options
    )

    $selectedOption = $null
    while ($selectedOption -eq $null) {
        Write-Host "Please select one of the available options:"
        for ($i = 0; $i -lt $Options.Length; $i++) {
            Write-Host "$($i + 1): $($Options[$i])"
        }
        $input = Read-Host
        if ([int]::TryParse($input, [ref]$null)) {
            $index = [int]$input - 1
            if ($index -ge 0 -and $index -lt $Options.Length) {
                $selectedOption = $Options[$index]
            }
        }
    }

    return $selectedOption
}

$ACTION = Select-Option -Options $ACTIONS
$ENV = Select-Option -Options $ENVIRONMENTS
$ENV_L = $ENV.ToLower()

Write-Output "Action: ${ACTION} to apply on ${ENV} environment"


# Extract variables from config files
$GCP = (Get-Content "./config/GCP/project.${ENV}.json" | Out-String | ConvertFrom-Json).GCP
$SLT = (Get-Content "./config/solution.json" | Out-String | ConvertFrom-Json).solution
$SERVICE = $SLT.code
$VERSION =  $SLT.version
$SERVICE_SLUG = $SOL.slug
$PROJECT = $GCP.id
$REGION = $GCP.region
$PROJECT_NUMBER = $GCP.number

if($ACTION -eq "APPLY TERRAFORM"){
    # Initiate Terraform
    docker run --rm -i `
     -v "${pwd}:/tf" `
     -e "GOOGLE_APPLICATION_CREDENTIALS=/tf/credentials/${ENV}/deployer.keyfile.json" `
     hashicorp/terraform:latest `
     "-chdir=/tf/iac/GCP" init "-backend-config=/tf/iac/GCP/backend.${ENV}.conf" -reconfigure

    # Validate Terraform
    docker run --rm -i `
     -v "${pwd}:/tf" `
     -e "GOOGLE_APPLICATION_CREDENTIALS=/tf/credentials/${ENV}/deployer.keyfile.json" `
     hashicorp/terraform:latest `
     "-chdir=/tf/iac/GCP" validate


    # Apply Terraform
    docker run --rm -i `
     -v "${pwd}:/tf" `
     -v "/var/run/docker.sock:/var/run/docker.sock" `
     -e "GOOGLE_APPLICATION_CREDENTIALS=/tf/credentials/${ENV}/deployer.keyfile.json" `
     hashicorp/terraform:latest `
      "-chdir=/tf/iac/GCP" apply `
      "-var-file=/tf/config/solution.json" `
      "-var-file=/tf/config/GCP/project.${ENV}.json" `
      "-var-file=/tf/config/GCP/services.json"

}