variable "project" {}
variable "cloud_run_service_name" {}
variable "security_policy" {}

output "ip_address" {
  value = google_compute_global_address.hello_lb_ip.address
}

resource "google_compute_global_forwarding_rule" "hello_forwarding_rule_http" {
  name                  = "hello-forwarding-rule-http"
  description           = "load balancerのforwarding rule(http)"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_http_proxy.hello_target_http_proxy.id
  ip_address            = google_compute_global_address.hello_lb_ip.address
  ip_protocol           = "TCP"
  port_range            = "80"
}

resource "google_compute_global_address" "hello_lb_ip" {
  name         = "hello-lb-ip"
  description  = "load balancerの静的IP"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
  project      = var.project
}

resource "google_compute_target_http_proxy" "hello_target_http_proxy" {
  name    = "predictor-target-http-proxy"
  url_map = google_compute_url_map.hello_url_map.id
}

# url map
resource "google_compute_url_map" "hello_url_map" {
  name        = "hello-lb"
  description = "load balancer用のlb"

  default_service = google_compute_backend_service.hello_backend_service.id

  path_matcher {
    name            = "hello-apps"
    default_service = google_compute_backend_service.hello_backend_service.id
  }
}

resource "google_compute_backend_service" "hello_backend_service" {
  name                  = "hello-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  load_balancing_scheme = "EXTERNAL_MANAGED"

  # cloud armor policyを指定
  security_policy = var.security_policy

  backend {
    group = google_compute_region_network_endpoint_group.hello_neg.self_link
  }
}

# Load Balancerのserverless NEG
resource "google_compute_region_network_endpoint_group" "hello_neg" {
  name                  = "hello-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "asia-northeast1"
  # cloud runのserviceを指定
  cloud_run {
    service = var.cloud_run_service_name
  }
}
