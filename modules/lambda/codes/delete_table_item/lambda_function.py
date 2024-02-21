import json
import logging
import os

import requests
from pymongo import MongoClient
import boto3
from botocore.exceptions import ClientError


def get_secret():
    secret_name = "app-docdb-secret"
    region_name = "us-east-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(service_name="secretsmanager", region_name=region_name)

    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        raise e

    secret = get_secret_value_response["SecretString"]
    return json.loads(secret)


def download_pem_file() -> bool:
    # URL에서 파일을 가져옵니다.
    response = requests.get(
        "https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem"
    )
    # HTTP 요청이 성공했는지 확인합니다 (상태 코드 200).
    if response.status_code == 200:
        # 파일을 쓰기 모드로 열고 내용을 기록합니다.
        with open("global-bundle.pem", "wb") as file:
            file.write(response.content)
        return True
    else:
        return False


# 로거 설정

logger = logging.getLogger()
logger.setLevel(logging.INFO)
dynamodb = boto3.resource("dynamodb")
dynamodb_table_name = os.environ["DYNAMODB_TABLE_NAME"]
table = dynamodb.Table(dynamodb_table_name)
rekognition = boto3.client("rekognition")
secret = get_secret()
mongo_client = MongoClient(
    host=secret["host"],
    port=27017,
    username=secret["username"],
)

secret = get_secret()
logging.info("Getting DocumentDB secret")

download_success = download_pem_file()
if not download_success:
    logging.error("Failed to download global-bundle.pem file.")
    exit(1)
else:
    logging.info("Downloaded global-bundle.pem file.")


mongo_client = MongoClient(
    f"mongodb://{secret['username']}:{secret['password']}@{secret['host']}:{secret['port']}/?tls=true&tlsCAFile=global-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
)
db = mongo_client["image_metadata"]
collection = db["caption_vector"]


def delete_face_ids(face_ids, user_id):
    try:
        response = rekognition.delete_faces(CollectionId=user_id, FaceIds=face_ids)
        logger.info(f"Deleted {face_ids} from Rekognition")
        return response
    except Exception as e:
        logger.error(f"Error deleting {face_ids} from Rekognition: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps(f"Error deleting {face_ids} from Rekognition: {str(e)}"),
        }


def lambda_handler(event, context):
    # Boto3 클라이언트 생성

    # SNS 메시지에서 S3 오브젝트 정보 추출
    for record in event["Records"]:
        # SNS 메시지 본문 파싱
        message = json.loads(record["Sns"]["Message"])
        # S3 오브젝트 정보 추출
        for s3_record in message["Records"]:
            file_name = s3_record["s3"]["object"]["key"]
            base_file_name = file_name.split("/")[-1]
            user_id = file_name.split("/")[1]
            # DynamoDB에서 해당 file_name으로 face_ids 조회
            try:
                item = table.get_item(
                    Key={"file_name": base_file_name, "user_id": user_id}
                )

                if "Item" not in item:
                    logger.error(f"File {file_name} not found in DynamoDB")
                    return {
                        "statusCode": 404,
                        "body": json.dumps(f"File {file_name} not found in DynamoDB"),
                    }

                if item["Item"].get("face_ids") is not None:
                    face_ids = json.loads(item["Item"]["face_ids"])
                    delete_face_response = delete_face_ids(face_ids, user_id)

                delete_response = table.delete_item(
                    Key={"file_name": base_file_name, "user_id": user_id}
                )

                logger.info(
                    f"Deleted {file_name} record from DynamoDB: {delete_response}"
                )
                
                collection.delete_one({"file_name": base_file_name})
                
                logger.info(f"Deleted {file_name} record from DocumentDB")
                

            except Exception as e:
                logger.error(f"Error processing {file_name}: {str(e)}")
                return {
                    "statusCode": 500,
                    "body": json.dumps(f"Error processing {file_name}: {str(e)}"),
                }

    return {"statusCode": 200, "body": json.dumps("Process completed.")}
