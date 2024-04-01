provider "google" {

	project 	= var.GCP.id
	region  	= var.GCP.region
	zone    	= var.GCP.zone

	batching {
		enable_batching = false
	}

}

provider "google-beta" {

	project 	= var.GCP.id
	region  	= var.GCP.region
	zone    	= var.GCP.zone

	batching {
		enable_batching = false
	}


}

terraform {

    backend "gcs" {}

}