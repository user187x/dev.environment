terraform {
  source = "../../modules/aws_on_k8s"
}

# This generates a 'mock' provider file dynamically
generate "mock_provider" {
  path      = "mock_test.tftest.hcl"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
mock_provider "aws" {
  # This intercepts all AWS calls
}

run "visualize_logic" {
  command = plan
  assert {
    condition     = aws_s3_bucket.mock_bucket.bucket == "my-mock-bucket-terragrunt-test"
    error_message = "The naming logic is broken!"
  }
}
EOF
}
