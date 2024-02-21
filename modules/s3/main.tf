


### S3 Bucket for storing images
resource "aws_s3_bucket" "app_image_bucket" {
  bucket = var.app_image_bucket_name


}

resource "aws_s3_bucket_public_access_block" "app-image-bucket-public-access-block" {
  bucket                  = aws_s3_bucket.app_image_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "app_image_bucket_policy" {
  bucket = aws_s3_bucket.app_image_bucket.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Action" : [
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Resource" : "${aws_s3_bucket.app_image_bucket.arn}/*"
        },
        {
          "Sid" : "AllowCloudFrontServicePrincipal",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "cloudfront.amazonaws.com"
          },
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::rapa-app-image-bucket/*",
          "Condition" : {
            "StringEquals" : {
              "AWS:SourceArn" : "arn:aws:cloudfront::109412806537:distribution/E3DGL65NQD7DE4"
            }
          }
        }
      ]
    }
  )
  depends_on = [aws_s3_bucket.app_image_bucket]
}


resource "aws_s3_bucket_cors_configuration" "example" {
  bucket = aws_s3_bucket.app_image_bucket.id

  # cors_rule {
  #   allowed_headers = ["*"]
  #   allowed_methods = ["GET"]
  #   allowed_origins = ["https://www.amazonphotoquery.site"]
  #   expose_headers  = ["ETag"]
  #   max_age_seconds = 3000
  # }

  cors_rule {
    allowed_methods = ["GET", "HEAD"]
    allowed_headers = ["*"]
    allowed_origins = ["*"]
    expose_headers  = ["x-amz-server-side-encryption", "x-amz-request-id", "x-amz-id-2"]
  }

  # cors_rule {
  #   allowed_headers = ["*"]
  #   allowed_methods = ["GET"]
  #   allowed_origins = ["https://s3.amazonphotoquery.site"]
  # }


}

data "aws_lambda_function" "app_image_resize_lambda" {
  function_name = "app-image-resize"
}

data "aws_lambda_function" "app_on_obeject_created_lambda" {
  function_name = "app_on_object_created"
}



resource "aws_s3_bucket_notification" "app_s3_notification" {
  bucket = aws_s3_bucket.app_image_bucket.id



  topic {
    id            = "on_object_created"
    topic_arn     = var.app_on_object_created_topic_arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "original/"
  }

  topic {
    id            = "on_object_deleted"
    topic_arn     = var.app_on_object_deleted_topic_arn
    events        = ["s3:ObjectRemoved:*"]
    filter_prefix = "original/"
  }


}


### S3 Bucket for front-end
resource "aws_s3_bucket" "app_frontend_bucket" {
  bucket = var.app_frontend_bucket_name
}



resource "aws_s3_bucket_object" "frontend_index_html" {
  bucket       = aws_s3_bucket.app_frontend_bucket.id
  key          = "index.html"
  source       = "./index.html"
  etag         = filemd5("./index.html")
  content_type = "text/html"
  depends_on   = [aws_s3_bucket.app_frontend_bucket]
}


####

resource "aws_s3_bucket" "app_lambda_code_bucket" {
  bucket = "app-lambda-code-bucket"
}