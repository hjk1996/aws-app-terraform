import os
import logging
import json
import boto3
from PIL import Image
import io

# 로깅 설정
logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3_client = boto3.client("s3")

image_size = int(os.environ.get("IMAGE_SIZE", 300))
bucket_name = os.environ.get("BUCKET_NAME", "rapa-app-image-bucket")


def resize_image_in_memory(image_data, resized_path):
    # 바이트 데이터를 이용하여 이미지 메모리에 로드
    with Image.open(io.BytesIO(image_data)) as image:
        # 이미지 리사이즈 (예: 300x300)
        image.thumbnail((image_size, image_size))

        # 리사이즈된 이미지 저장을 위한 바이트 스트림 생성
        with io.BytesIO() as output:
            image.save(output, format=image.format)
            data = output.getvalue()

    # 리사이즈된 이미지를 S3에 저장
    s3_client.put_object(Bucket=bucket_name, Key=resized_path, Body=data)
    logger.info(f"Image saved to S3: {resized_path}")


def lambda_handler(event, context):
    logger.info("Event: " + json.dumps(event))

    # SQS 메시지 처리
    for record in event["Records"]:
        body = json.loads(record["body"])
        # SNS 메시지 형식의 실제 메시지 파싱
        sns_message = json.loads(body["Message"])
        # SNS 메시지 본문에서 S3 이벤트 정보 추출
        for s3_record in sns_message["Records"]:
            bucket = s3_record["s3"]["bucket"]["name"]
            key = s3_record["s3"]["object"]["key"]
            logger.info(f"Processing file: {key} from bucket: {bucket}")

            # S3에서 이미지 바이트 데이터를 메모리로 직접 로드
            try:
                response = s3_client.get_object(Bucket=bucket, Key=key)
                image_data = response["Body"].read()
            except s3_client.exceptions.NoSuchKey as e:
                logger.info(f"File not found: {key}")
                continue

            # 리사이징할 이미지의 저장 경로
            user_id = key.split("/")[1]
            base_file_name = key.split("/")[-1]
            resized_path = f"thumbnail/{user_id}/{base_file_name}"
            # 이미지 리사이징 및 S3에 저장
            resize_image_in_memory(image_data, resized_path)
            logger.info(f"Resized image saved to {resized_path}")
