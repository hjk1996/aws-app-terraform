resource "aws_dynamodb_table" "app_face_ids_table" {
  name         = "AppFaceIds"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "file_name"
  range_key    = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "file_name"
    type = "S"
  }

}


####################


resource "aws_dynamodb_table" "app_image_caption_table" {
  name         = "AppImageCaption"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "file_name"
  range_key    = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "file_name"
    type = "S"
  }


  tags = {
    "Terraform" = "true"
  }
}


####################


resource "aws_dynamodb_table" "app_image_metadata_table" {
  name         = "AppImageMetadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "file_name"
  range_key    = "user_id"
  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "file_name"
    type = "S"
  }


  tags = {
    "Terraform" = "true"
  }
}