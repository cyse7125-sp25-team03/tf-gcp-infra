resource "google_storage_bucket" "trace-bucket" {
  name          = "trace-bucket-${var.environment}"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}
//creates empty folder in the bucket
resource "google_storage_bucket_object" "uploads_folder" {
  name    = "uploads/"
  bucket  = google_storage_bucket.trace-bucket.name
  content = " "
}