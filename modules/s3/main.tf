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
        }
      ]

    }
  )
  depends_on = [aws_s3_bucket.app_image_bucket]
}

resource "aws_s3_bucket_notification" "s3_nsfw_detect_lambda_notification" {
  bucket = aws_s3_bucket.app_image_bucket.id
  lambda_function {
    lambda_function_arn = var.app_nsfw_detect_lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpg"
  }
  lambda_function {
    lambda_function_arn = var.app_nsfw_detect_lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpeg"
  }

  lambda_function {
    lambda_function_arn = var.app_nsfw_detect_lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".png"
  }
  lambda_function {
    lambda_function_arn = var.app_nsfw_detect_lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".webp"
  }
  depends_on = [aws_s3_bucket.app_image_bucket, var.app_nsfw_detect_lambda_arn]

}