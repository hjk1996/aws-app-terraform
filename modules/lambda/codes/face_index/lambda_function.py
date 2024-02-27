import os
import json
import logging
import boto3

# 로깅 설정
logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO
)
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# AWS 서비스 클라이언트 생성
rekognition_client = boto3.client("rekognition")
s3_client = boto3.client("s3")
dynamodb = boto3.resource("dynamodb")

# 환경변수에서 DynamoDB 테이블 이름 가져오기
dynamodb_table_name = os.environ["DYNAMODB_TABLE_NAME"]
table = dynamodb.Table(dynamodb_table_name)


def index_face(user_id: str, bucket_name: str, file_name: str, base_file_name: str):
    return rekognition_client.index_faces(
        CollectionId=user_id,
        Image={"S3Object": {"Bucket": bucket_name, "Name": file_name}},
        ExternalImageId=base_file_name,
        MaxFaces=10,
        QualityFilter="AUTO",
        DetectionAttributes=["ALL"],
    )


def lambda_handler(event, context):
    # SQS 메시지 처리
    for record in event["Records"]:
        # SQS 메시지 본문에서 SNS 메시지 본문 파싱
        body = json.loads(record["body"])
        sns_message = json.loads(body["Message"])

        # SNS 메시지 본문에서 S3 이벤트 정보 추출
        for s3_record in sns_message["Records"]:
            bucket_name = s3_record["s3"]["bucket"]["name"]
            file_name = s3_record["s3"]["object"]["key"]
            user_id = file_name.split("/")[1]
            base_file_name = file_name.split("/")[-1]

            # DynamoDB에 파일 정보 저장
            response = table.put_item(
                Item={"file_name": base_file_name, "user_id": user_id}
            )

            # DynamoDB 저장 결과 로깅
            if response["ResponseMetadata"]["HTTPStatusCode"] == 200:
                logger.info(f"Successfully saved file {file_name} to DynamoDB")
            else:
                logger.error(f"Error saving file {file_name} to DynamoDB: {response}")
                return {
                    "statusCode": 500,
                    "body": json.dumps("Error saving file to DynamoDB."),
                }

            try:
                index_response = index_face(
                    user_id=user_id,
                    bucket_name=bucket_name,
                    file_name=file_name,
                    base_file_name=base_file_name,
                )
            except rekognition_client.exceptions.ResourceNotFoundException as e:
                rekognition_client.create_collection(CollectionId=user_id)
                logger.info(f"Created new collection with ID: {user_id}")
                index_response = index_face(
                    user_id=user_id,
                    bucket_name=bucket_name,
                    file_name=file_name,
                    base_file_name=base_file_name,
                )
            except Exception as e:
                logger.error(f"Error indexing faces: {str(e)}")
                return {
                    "statusCode": 500,
                    "body": json.dumps("Error indexing faces."),
                }

            face_ids = [
                face["Face"]["FaceId"] for face in index_response["FaceRecords"]
            ]
            if face_ids:
                face_ids_str = json.dumps(face_ids)
                try:
                    table.update_item(
                        Key={"file_name": base_file_name, "user_id": user_id},
                        UpdateExpression="SET face_ids = :val1",
                        ExpressionAttributeValues={":val1": face_ids_str},
                    )
                    logger.info(
                        f"Successfully saved face IDs to DynamoDB for file {file_name}"
                    )
                except Exception as e:
                    logger.error(f"Error saving face IDs to DynamoDB: {str(e)}")

    return {
        "statusCode": 200,
        "body": json.dumps("Face analysis and DynamoDB update completed."),
    }
