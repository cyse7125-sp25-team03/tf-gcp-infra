resource "google_secret_manager_secret" "postgres_username" {
  secret_id = "postgres-username"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "postgres_username_version" {
  secret      = google_secret_manager_secret.postgres_username.id
  secret_data = var.postgres_username
}

resource "google_secret_manager_secret" "postgres_password" {
  secret_id = "postgres-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "postgres_password_version" {
  secret      = google_secret_manager_secret.postgres_password.id
  secret_data = var.postgres_password
}

resource "google_secret_manager_secret" "kafka_username" {
  secret_id = "kafka-username"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "kafka_username_version" {
  secret      = google_secret_manager_secret.kafka_username.id
  secret_data = var.kafka_username
}

resource "google_secret_manager_secret" "kafka_password" {
  secret_id = "kafka-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "kafka_password_version" {
  secret      = google_secret_manager_secret.kafka_password.id
  secret_data = var.kafka_password
}