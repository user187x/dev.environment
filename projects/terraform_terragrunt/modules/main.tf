provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "aws" {
  region = "us-east-1"
}

resource "kubernetes_namespace" "env" {
  metadata { name = "terragrunt-test" }
}

resource "aws_s3_bucket" "mock_bucket" {
  bucket = "my-mock-bucket-${kubernetes_namespace.env.metadata[0].name}"
}

output "bucket_name" {
  value = aws_s3_bucket.mock_bucket.bucket
}
