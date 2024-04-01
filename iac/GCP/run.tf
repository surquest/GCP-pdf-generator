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
                name       = "gcsAssets"
                mount_path = "/app/template"
            }
            ports {
                container_port = each.value.container.ports.containerPort
            }
        }
        
        volumes {
            name = "gcsAssets"  # must match volume_mounts.name
            gcs {
                bucket = google_storage_bucket.buckets["assets"].name
                read_only = false
            }
        }

        labels = {
            solution = var.solution.slug
            env      = var.GCP.env
        }
    
    }
}
