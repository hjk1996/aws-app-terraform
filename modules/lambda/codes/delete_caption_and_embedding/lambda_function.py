import boto3
import json
import logging

# 로거 설정
logger = logging.getLogger()
logger.setLevel(logging.INFO)
dynamodb = boto3.client('dynamodb')
def lambda_handler(event, context):
    # Boto3 클라이언트 생성

    # SNS 메시지에서 S3 오브젝트 정보 추출
    for record in event['Records']:
        # SNS 메시지 본문 파싱
        message = json.loads(record['Sns']['Message'])

        # S3 오브젝트 정보 추출
        for s3_record in message['Records']:
            bucket_name = s3_record['s3']['bucket']['name']
            file_name = s3_record['s3']['object']['key']
            user_id = file_name.split('/')[1]
            logger.info(f"Processing {file_name} from {bucket_name}")
            # DynamoDB에서 해당 file_name으로 face_ids 조회
            try:                
                pass
            except Exception as e:
                logger.error(f"Error processing {file_name}: {str(e)}")

    return {"statusCode": 200, "body": json.dumps("Process completed.")}
