## Project Zero Go Home

## IAM Service Account
resource "google_service_account" "zero" {
    account_id = "zero-service-account"
    display_name = "Project Zero service account"
}

resource "google_project_iam_member" "zero-container" {
    role = "roles/container.admin"
    member = "serviceAccount:${google_service_account.zero.email}"
}

resource "google_project_iam_member" "zero-compute" {
    role = "roles/compute.admin"
    member = "serviceAccount:${google_service_account.zero.email}"
}

resource "google_compute_network" "zero" {
    name = "zero-vpc"
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "zero" {
    name = "zero-subnet"
    ip_cidr_range = "10.0.0.0/16"
    region = var.region
    network = google_compute_network.zero.id
}

resource "google_compute_address" "zero" {
    region = var.region
    name = "zero-ipv4"
}

resource "google_compute_firewall" "zero" {
    name = "zero-firewall"
    network = google_compute_network.zero.name
    
    allow {
        protocol = "icmp"
    }

    allow {
        protocol = "tcp"
        ports = ["22"]
    }
}

resource "google_compute_instance" "zero" {
    name = "zero"
    #machine_type = "e2-small"
    machine_type = "c2-standard-4"
    zone = var.zone

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
        subnetwork = google_compute_subnetwork.zero.name
        access_config {
            nat_ip = google_compute_address.zero.address
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
        email = google_service_account.zero.email
        scopes = ["cloud-platform"]
    }

    metadata = {
        ssh-keys = "${var.username}:${var.ssh_public_key}"
    }

    labels = {
        zero = "home"
    }
}

resource "google_container_cluster" "zero" {
    name = "zero-container-cluster"
    count = 1
    initial_node_count = 3
    location = var.zone
    network = google_compute_network.zero.name
    subnetwork = google_compute_subnetwork.zero.name

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
      "zero" = "home-container-cluster"
    }
}
