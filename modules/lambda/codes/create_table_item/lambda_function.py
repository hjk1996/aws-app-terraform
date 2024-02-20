import os
import json
import logging

import boto3


logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO
)
# 로거 설정
logger = logging.getLogger()
logger.setLevel(logging.INFO)

rekognition_client = boto3.client("rekognition")
s3_client = boto3.client("s3")
dynamodb = boto3.resource("dynamodb")
dynamodb_table_name = os.environ["DYNAMODB_TABLE_NAME"]
table = dynamodb.Table(dynamodb_table_name)

def lambda_handler(event, context):
    # SNS 메시지 처리
    for record in event['Records']:
        # SNS 메시지 본문 파싱
        sns_message = json.loads(record['Sns']['Message'])
        
        # SNS 메시지 본문에서 S3 이벤트 정보 추출
        for s3_record in sns_message['Records']:
            bucket_name = s3_record['s3']['bucket']['name']
            file_name = s3_record['s3']['object']['key']
            user_id = file_name.split('/')[1]
            base_file_name = file_name.split("/")[-1]
            response = table.put_item(
                Item={
                    "file_name": file_name,
                    "user_id": user_id
                }
            )
            
            if response["ResponseMetadata"]["HTTPStatusCode"] == 200:
                logger.info(f"Successfully saved file {file_name} to DynamoDB")
            else:
                logger.error(f"Error saving file {file_name} to DynamoDB: {response}")
                return {"statusCode": 500, "body": json.dumps("Error saving file to DynamoDB.")}
            
            
            
            # 이하 로직은 동일하게 유지
            existing_collections = set(rekognition_client.list_collections()['CollectionIds'])
            if user_id not in existing_collections:
                rekognition_client.create_collection(CollectionId=user_id)
                logger.info(f"Created new collection with ID: {user_id}")
            else:
                logger.info(f"Collection {user_id} already exists.")

            index_response = rekognition_client.index_faces(
                CollectionId=user_id,
                Image={"S3Object": {"Bucket": bucket_name, "Name": file_name}},
                ExternalImageId=base_file_name,
                MaxFaces=10,
                QualityFilter="AUTO",
                DetectionAttributes=["ALL"],
            )
            
            logger.info(index_response)
            face_ids = [face['Face']['FaceId'] for face in index_response['FaceRecords']]
            if face_ids:
                face_ids_str = json.dumps(face_ids)
                try:
                    table.update_item(
                        Key={"file_name": file_name, "user_id": user_id},
                        UpdateExpression="SET face_ids = :val1",
                        ExpressionAttributeValues={":val1": face_ids_str},
                    )
                    logger.info(f"Successfully saved face IDs to DynamoDB for file {file_name}")
                except Exception as e:
                    logger.error(f"Error saving face IDs to DynamoDB: {str(e)}")

    return {"statusCode": 200, "body": json.dumps("Face analysis and DynamoDB update completed.")}