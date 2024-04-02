# Create Cloud RuN

resource "google_cloud_run_v2_service" "services" {

    provider = google-beta

    for_each = var.services.run.services

    name = jsondecode(templatefile(
        "../../config/naming.patterns.json",
        {
        solution = var.solution,
        services = var.services,
        GCP      = var.GCP
        }
    ))["run"]["services"][each.key]

    location = var.GCP.region
    ingress = "INGRESS_TRAFFIC_ALL"
    launch_stage = "BETA"

    template {
        execution_environment = "EXECUTION_ENVIRONMENT_GEN2"
        service_account = google_service_account.accounts[each.value.serviceAccount].email

        containers {
            image = each.value.container.image
            volume_mounts {
                name       = "assetTemplate"
                mount_path = "/app/template"
            }
            # This part would persist the rendered PDFs (negative impact on PDF generation time)
            # volume_mounts {
            #     name       = "assetRender"
            #     mount_path = "/app/render"
            # }
            ports {
                container_port = each.value.container.ports.containerPort
            }
        }
        
        volumes {
            name = "assetTemplate"  # must match volume_mounts.name
            gcs {
                bucket = google_storage_bucket.buckets["templates"].name
                read_only = false
            }
        }

        # This part would persist the rendered PDFs (negative impact on PDF generation time)
        # 
        # volumes {
        #     name = "assetRender"  # must match volume_mounts.name
        #     gcs {
        #         bucket = google_storage_bucket.buckets["renders"].name
        #         read_only = false
        #     }
        # }

        labels = {
            solution = var.solution.slug
            env      = var.GCP.env
        }
    
    }
}

# Summarize map of Cloud Run services and access
locals{
    run_service_access = {
        for runKey, runVal in flatten([
            for key, value in var.services.run.services: [
                for item in value.access: {
                    idx             = "${key}.${item.role}.${item.type}.${item.key == null ? "-" : item.key}.${item.email == null ? "-" : item.email}"
                    serviceKey      = key
                    role            = item.role
                    type            = item.type
                    key             = item.key
                    email           = item.email
                }
            ]
        ]): runVal.idx => {
            serviceKey = runVal.serviceKey
            role = runVal.role
            type = runVal.type
            key = runVal.key
            email = runVal.email
            member = runVal.email != null ? "${runVal.type}:${runVal.email}" : "${runVal.type}:${google_service_account.accounts[runVal.key].email}"
        }
    }
}

# Set Cloud Run service access
resource "google_cloud_run_service_iam_member" "service_iam_binding" {

    for_each = local.run_service_access

    service = google_cloud_run_v2_service.services[each.value.serviceKey].name
    role    = each.value.role
    member  = each.value.member
}