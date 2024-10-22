variable "ip_addresses" {}

output "security_policy" {
  value = google_compute_security_policy.hello_policy.self_link
}

# Load Balancerのcloud armor policy
resource "google_compute_security_policy" "hello_policy" {
  name        = "hello-policy"
  description = "Load Balancer用のcloud armor policy"
  rule {
    action   = "allow"
    priority = 1000
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = var.ip_addresses
      }
    }
    description = "my home global ip address"
  }
  rule {
    action   = "deny(403)"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }
  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable = true
    }
  }
}
