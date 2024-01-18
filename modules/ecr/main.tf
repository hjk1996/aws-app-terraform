locals {
  ecr_policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 2
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_repository" "app_nsfw_detect_lambda_repo" {
  name = "app-nsfw-detect-lambda"
}


resource "aws_ecr_lifecycle_policy" "app_nsfw_detect_lambda_repo_lifecycle_policy" {
  repository = aws_ecr_repository.app_nsfw_detect_lambda_repo.name
  policy     = local.ecr_policy
}

resource "aws_ecr_repository" "app_hate_speech_detector_repo" {
  name = "app-hate-speech-detector"

}

resource "aws_ecr_lifecycle_policy" "app_hate_speech_detector_repo_lifecycle_policy" {
  repository = aws_ecr_repository.app_hate_speech_detector_repo.name
  policy     = local.ecr_policy
}