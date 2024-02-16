import boto3
import json
import logging

# 로거 설정
logger = logging.getLogger()
logger.setLevel(logging.INFO)

rekognition_client = boto3.client("rekognition")
s3_client = boto3.client("s3")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("AppFaceIds")

def lambda_handler(event, context):
    # SNS 메시지 처리
    for record in event['Records']:
        # SNS 메시지 본문 파싱
        sns_message = json.loads(record['Sns']['Message'])
        
        # SNS 메시지 본문에서 S3 이벤트 정보 추출
        for s3_record in sns_message['Records']:
            bucket_name = s3_record['s3']['bucket']['name']
            file_name = s3_record['s3']['object']['key']

            # S3 오브젝트 메타데이터에서 user_id 가져오기
            try:
                response = s3_client.head_object(Bucket=bucket_name, Key=file_name)
                user_id = response['Metadata'].get('user_id', '')  # 메타데이터에 user_id가 없을 경우 기본값 ''
            except Exception as e:
                logger.error(f"Error getting metadata for object {file_name} in bucket {bucket_name}: {str(e)}")
                continue  # 메타데이터 조회 실패 시 다음 레코드로 넘어감

            if not user_id:
                logger.error("No User Id in metadata")
                continue

            base_file_name = file_name.split("/")[-1]

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
                    table.put_item(
                        Item={
                            'user_id': user_id,
                            'file_name': file_name,
                            'face_ids': face_ids_str,
                        }
                    )
                    logger.info(f"Successfully saved face IDs to DynamoDB for file {file_name}")
                except Exception as e:
                    logger.error(f"Error saving face IDs to DynamoDB: {str(e)}")

    return {"statusCode": 200, "body": json.dumps("Face analysis and DynamoDB update completed.")}