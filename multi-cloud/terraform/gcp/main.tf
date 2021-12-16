## GCP Environment

## Locals
locals {
  region = join("-", slice(split("-", var.zone), 0, 2))
  zone = var.zone
  project = var.project
}

## IAM Service Account
resource "google_service_account" "grove" {
    account_id = "grove-service-account"
    display_name = "Project grove service account"
}

resource "google_project_iam_member" "grove-container" {
    role = "roles/container.admin"
    member = "serviceAccount:${google_service_account.grove.email}"
    project = local.project
}

resource "google_project_iam_member" "grove-compute" {
    role = "roles/compute.admin"
    member = "serviceAccount:${google_service_account.grove.email}"
    project = local.project
}

resource "google_compute_network" "grove" {
    name = "grove-vpc"
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "grove" {
    name = "grove-subnet"
    ip_cidr_range = "10.0.0.0/16"
    region = local.region
    network = google_compute_network.grove.id
}

resource "google_compute_address" "grove" {
    region = local.region
    name = "grove-ipv4"
}

resource "google_compute_firewall" "grove" {
    name = "grove-firewall"
    network = google_compute_network.grove.name
    source_ranges = [ "0.0.0.0/0" ]
    
    allow {
        protocol = "icmp"
    }

    allow {
        protocol = "tcp"
        ports = ["22"]
    }
}

resource "google_compute_instance" "grove" {
    name = "grove"
    #machine_type = "e2-small"
    machine_type = "c2-standard-4"
    zone = local.zone

    allow_stopping_for_update = true
    metadata_startup_script = file("metadata-script.sh")

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
            #image = "ubuntu-os-cloud/ubuntu-minimal-2004-lts"
            #image = "ubuntu-os-cloud/ubuntu-minimal-2010"
            size = 32
            #type = "pd-standard"
            type = "pd-ssd"
        }
    }

    ## 0 or 2 is required on 16 c2-standard-16
    # scratch_disk {
    #     interface = "NVME"
    # }
    # scratch_disk {
    #     interface = "NVME"
    # }
    # scratch_disk {
    #     interface = "NVME"
    # }
    # scratch_disk {
    #     interface = "NVME"
    # }

    network_interface {
        subnetwork = google_compute_subnetwork.grove.name
        access_config {
            nat_ip = google_compute_address.grove.address
        }
    }

    scheduling {
        ## Preemptible instance
        preemptible = true
        automatic_restart = false
        on_host_maintenance = "TERMINATE"

        ## Nonpremptible instance
        # preemptible = false
        # automatic_restart = true 
        # on_host_maintenance = "MIGRATE"
    }

    service_account {
        email = google_service_account.grove.email
        scopes = ["cloud-platform"]
    }

    metadata = {
        ssh-keys = "${var.username}:${var.ssh_public_key}"
    }

    labels = {
        grove = "home"
    }
}

resource "google_container_cluster" "grove" {
    name = "grove-container-cluster"
    count = 0
    initial_node_count = 1
    location = local.zone
    network = google_compute_network.grove.name
    subnetwork = google_compute_subnetwork.grove.name

    release_channel {
        channel = "RAPID"
    }

    node_config {
        preemptible = true
        machine_type = "e2-small"
        metadata = {
            disable-legacy-endpoints = true
        }
    }

    resource_labels = {
      "grove" = "home-container-cluster"
    }
}
