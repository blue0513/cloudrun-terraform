variable "project" {}
variable "region" {}

output "service_name" {
  value = google_cloud_run_v2_service.hello_cloud_run.name
}

resource "google_cloud_run_v2_service" "hello_cloud_run" {
  name        = "hello"
  location    = var.region
  description = "cloud run service"
  ingress     = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER" # 内部ロードバランサーからのトラフィックのみを許可します

  template {
    containers {
      name  = "hello"
      image = "us-docker.pkg.dev/cloudrun/container/hello:latest"
      resources {
        cpu_idle = false
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }

  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST" # 最新のリビジョン（デプロイメント）にトラフィックを送信することを指定
    percent = 100
  }

  deletion_protection = false # 削除保護を無効にする (terraform destroy時に削除できるようにする)
}

# Cloud Runの未認証呼び出し許可を付与
resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_v2_service.hello_cloud_run.location
  project  = var.project
  service  = google_cloud_run_v2_service.hello_cloud_run.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

# Cloud Runの未認証呼び出し許可policy (本番環境ではmembersに適切な値を設定すること)
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}
