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
       
      ]
    }
  )
  depends_on = [aws_s3_bucket.app_image_bucket]
}


resource "aws_s3_bucket_cors_configuration" "example" {
  bucket = aws_s3_bucket.app_image_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["https://www.amazonphotoquery.site"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

data "aws_lambda_function" "app_image_resize_lambda" {
  function_name = "app-image-resize"
}


resource "aws_s3_bucket_notification" "s3_image_resize_lambda_notification" {
  bucket = aws_s3_bucket.app_image_bucket.id
  lambda_function {
    lambda_function_arn = data.aws_lambda_function.app_image_resize_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "original/"
    filter_suffix       = ".jpg"

  }
  lambda_function {
    lambda_function_arn = data.aws_lambda_function.app_image_resize_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "original/"
    filter_suffix       = ".jpeg"
  }

  lambda_function {
    lambda_function_arn = data.aws_lambda_function.app_image_resize_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "original/"
    filter_suffix       = ".png"
  }
  lambda_function {
    lambda_function_arn =data.aws_lambda_function.app_image_resize_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "original/"
    filter_suffix       = ".webp"
  }
  depends_on = [aws_s3_bucket.app_image_bucket, data.aws_lambda_function.app_image_resize_lambda]

}

### S3 Bucket for front-end
resource "aws_s3_bucket" "app_frontend_bucket" {
  bucket = var.app_frontend_bucket_name
}

# resource "aws_s3_bucket_policy" "app_frontend_bucket_policy" {
#   bucket = aws_s3_bucket.app_frontend_bucket.id
#   policy = jsonencode(
#     {

#       "Version" : "2012-10-17",
#       "Statement" : [
#         {
#           "Effect" : "Allow",
#           "Principal" : {
#             "Service" : "cloudfront.amazonaws.com"
#           },
#           "Action" : [
#             "s3:GetObject"
#           ],
#           "Resource" : "${aws_s3_bucket.app_frontend_bucket.arn}/*",
#           "Condition": {
#                 "StringEquals": {
#                     "AWS:SourceArn": "${var.app_frontend_cloudfront_arn}"
#                 }
#             }
#         }
#       ]

#     }
#   )
#   depends_on = [aws_s3_bucket.app_frontend_bucket]
# }


resource "aws_s3_bucket_object" "frontend_index_html" {
  bucket       = aws_s3_bucket.app_frontend_bucket.id
  key          = "index.html"
  source       = "./index.html"
  etag         = filemd5("./index.html")
  content_type = "text/html"
  depends_on   = [aws_s3_bucket.app_frontend_bucket]
}