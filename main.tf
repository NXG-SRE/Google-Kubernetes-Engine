provider "google" {
  credentials = file(var.account_file_path)
  project     = var.project_id
  region      = var.region
}

resource "google_container_cluster" "gke_cluster" {
  name     = var.cluster_name
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "gke_cluster_preemptible_nodes" {
  name       = "preemptible-node-pool"
  location   = var.region
  cluster    = google_container_cluster.gke_cluster.name
  node_count = var.default_node.count

  node_config {
    preemptible  = var.default_node.preemtible
    machine_type = var.default_node.type
    
    disk_size_gb = var.default_node.disk.size
    disk_type    = var.default_node.disk.type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
