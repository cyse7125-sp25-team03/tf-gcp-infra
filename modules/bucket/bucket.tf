resource "google_storage_bucket" "trace_bucket" {
  name          = var.trace_bucket_name
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}
//creates empty folder in the bucket
resource "google_storage_bucket_object" "uploads_folder" {
  name    = "uploads/"
  bucket  = google_storage_bucket.trace_bucket.name
  content = " "
}

resource "google_storage_bucket" "db_backups_bucket" {
  name          = var.backups_bucket_name
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}
//creates empty folder in the bucket
resource "google_storage_bucket_object" "backups_folder" {
  name    = "backups/"
  bucket  = google_storage_bucket.db_backups_bucket.name
  content = " "
}