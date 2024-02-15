import boto3
import json
import logging

# 로거 설정
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # Boto3 클라이언트 생성
    dynamodb = boto3.client('dynamodb')
    rekognition = boto3.client('rekognition')

    # 이벤트에서 S3 오브젝트 정보 추출
    for record in event['Records']:
        s3_info = record['s3']
        bucket_name = s3_info['bucket']['name']
        file_name = s3_info['object']['key']

        # DynamoDB에서 해당 file_name으로 face_ids 조회
        try:
            response = dynamodb.get_item(
                TableName='AppFaceIds',
                Key={'file_name': {'S': file_name}}
            )
            if 'Item' in response:
                user_id = response['Item']['user_id']['S']
                face_ids = json.loads(response['Item']['face_ids']['S'])

                # Rekognition에서 face_ids에 해당하는 얼굴 삭제
                if face_ids:
                    delete_response = rekognition.delete_faces(
                        CollectionId=user_id,
                        FaceIds=face_ids
                    )
                    logger.info(f"Deleted faces from Rekognition collection for {file_name}: {delete_response}")

                    # DynamoDB에서 해당 file_name 항목 삭제
                    delete_response = dynamodb.delete_item(
                        TableName='AppFaceIds',
                        Key={'file_name': {'S': file_name}}
                    )
                    logger.info(f"Deleted {file_name} record from DynamoDB: {delete_response}")
                else:
                    logger.info(f"No face_ids to delete for {file_name}")
            else:
                logger.info(f"No face_ids found for {file_name} in DynamoDB")
        except Exception as e:
            logger.error(f"Error processing {file_name}: {str(e)}")

    return {"statusCode": 200, "body": json.dumps("Process completed.")}
