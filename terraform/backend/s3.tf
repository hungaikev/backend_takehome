resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-ello-terraform-state-bucket"

}

resource "aws_dynamodb_table" "terraform_locks" {
  name           = "my-ello-terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}
