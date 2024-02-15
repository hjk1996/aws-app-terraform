resource "aws_dynamodb_table" "app_face_ids_table" {
  name           = "AppFaceIds"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "file_name"
  range_key      = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "file_name"
    type = "S"
  }

}
