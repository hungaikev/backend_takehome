
provider "aws" {
  region  = "eu-central-1"
  profile = "default"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-ello-terraform-state-bucket"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name           = "my-ello-terraform-locks"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_ecr_repository" "my_repository" {
  name = "my-ello-ecs-repository"
}


output "ello_ecr_repository_url" {
  value = aws_ecr_repository.my_repository.repository_url
}

output "s3-bucket" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb-table" {
  value = aws_dynamodb_table.terraform_locks.name
}
