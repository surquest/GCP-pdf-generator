# Array of environments to deploy to
$ENVIRONMENTS = @(
    # "PROD",
    "DEV"
    )
$ACTIONS = @(
    "APPLY TERRAFORM"
    # "DEPLOY CLOUD RUN"
    )
$PREFIX = "etl"

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


# if($ACTION -eq "DEPLOY CLOUD RUN"){
#     # configure Google Cloud
#     gcloud auth activate-service-account --key-file="./credentials/${ENV}/deployer.keyfile.json"
#     gcloud config set project $GCP.id
#     gcloud config set compute/zone $GCP.zone

#     # build and push docker image
#     docker build `
#      -t "us-central1-docker.pkg.dev/${PROJECT}/${PREFIX}--${ENV_L}/${SERVICE}/${ENV_L}" `
#      -f app.base.dockerfile `
#      --target app .

#     # login to GCP Container registry
#     cat credentials/${ENV}/deployer.keyfile.json | docker login -u _json_key --password-stdin "https://us-central1-docker.pkg.dev"

#     # push docker image to GCP Artifact Registry
#     docker push "us-central1-docker.pkg.dev/${PROJECT}/${PREFIX}--${ENV_L}/${SERVICE}/${ENV_L}"

#     # deploy to Google Cloud Run
#     gcloud run deploy "${PREFIX}--${SERVICE}--${ENV_L}" `
#      --region $REGION `
#      --tag $VERSION `
#      --image "us-central1-docker.pkg.dev/${PROJECT}/${PREFIX}--${ENV_L}/${SERVICE}/${ENV_L}:latest" `
#      --service-account "${PREFIX}--${SERVICE_SLUG}-runner--${ENV}@${project}.iam.gserviceaccount.com" `
#      --set-env-vars="ENVIRONMENT=${ENV}" `
#      --set-env-vars="PATH_PREFIX=/api/${PREFIX}--${SERVICE}--${ENV_L}/${VERSION}" `
#      --ingress internal-and-cloud-load-balancing `
#      --platform managed `
#      --no-allow-unauthenticated

#     # set IAM permissions for the service account runner to invoke the service
#     gcloud run services add-iam-policy-binding "${PREFIX}--${SERVICE}--${ENV_L}" `
#      --region $REGION `
#      --member="serviceAccount:${PREFIX}--${SERVICE_SLUG}-runner--${ENV}@${project}.iam.gserviceaccount.com" `
#      --role="roles/run.invoker"

#     # set IAM permissions for the IAP service account to invoke the service
#     gcloud run services add-iam-policy-binding "${PREFIX}--${SERVICE}--${ENV_L}" `
#      --region $REGION `
#      --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-iap.iam.gserviceaccount.com" `
#      --role="roles/run.invoker"
# }

if($ACTION -eq "APPLY TERRAFORM"){
    # Initiate Terraform
    docker run --rm -i `
     -v "${pwd}:/tf" `
     -e "GOOGLE_APPLICATION_CREDENTIALS=/tf/credentials/${ENV}/deployer.keyfile.json" `
     hashicorp/terraform:latest `
     "-chdir=/tf/iac/GCP" init "-backend-config=/tf/iac/GCP/backend.${ENV}.conf" -reconfigure

    # Import Terraform resource

    # docker run --rm -i `
    #  -v "${pwd}:/tf" `
    #  -v "/var/run/docker.sock:/var/run/docker.sock" `
    #  -e "GOOGLE_APPLICATION_CREDENTIALS=/tf/credentials/${ENV}/deployer.keyfile.json" `
    #  hashicorp/terraform:latest `
    #   "-chdir=/tf/deploy/GCP" import `
    #   "-var-file=/tf/config/config.solution.json" `
    #   "-var-file=/tf/config/config.cloud.google.env.${ENV}.json" `
    #   "-var-file=/tf/config/config.cloud.google.services.json"


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