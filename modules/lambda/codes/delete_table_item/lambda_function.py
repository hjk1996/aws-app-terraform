import json
import logging
import os


import boto3



# 로거 설정
logger = logging.getLogger()
logger.setLevel(logging.INFO)
dynamodb = boto3.client('dynamodb')
dynamodb_table_name = os.environ['DYNAMODB_TABLE_NAME']
table = dynamodb.Table(dynamodb_table_name)
rekognition = boto3.client('rekognition')



def delete_face_ids(face_ids, user_id):
    response = rekognition.delete_faces(
        CollectionId=user_id,
        FaceIds=face_ids
    )
    logger.info(f"Deleted {face_ids} from Rekognition")
    return response

def lambda_handler(event, context):
    # Boto3 클라이언트 생성

    # SNS 메시지에서 S3 오브젝트 정보 추출
    for record in event['Records']:
        # SNS 메시지 본문 파싱
        message = json.loads(record['Sns']['Message'])
        # S3 오브젝트 정보 추출
        for s3_record in message['Records']:
            file_name = s3_record['s3']['object']['key']
            user_id = file_name.split('/')[1]
            # DynamoDB에서 해당 file_name으로 face_ids 조회
            try:
                item = table.get_item(
                    Key={'file_name': file_name, 'user_id': user_id}
                )
                
                if 'Item' not in item:
                    logger.error(f"File {file_name} not found in DynamoDB")
                    return {"statusCode": 404, "body": json.dumps(f"File {file_name} not found in DynamoDB")}
                
                
                
                if item['Item']['face_ids']:
                    face_ids = json.loads(item['Item']['face_ids'])
                    delete_face_response = delete_face_ids(face_ids, user_id)
            
                
                
                delete_response = table.delete_item(
                            Key={'file_name': {'S': file_name},
                                 'user_id': {'S': user_id}
                                 }
                )
                logger.info(f"Deleted {file_name} record from DynamoDB: {delete_response}")
            except Exception as e:
                logger.error(f"Error processing {file_name}: {str(e)}")

    return {"statusCode": 200, "body": json.dumps("Process completed.")}
