import os
import json
import boto3

region_aws = os.getenv('REGION_AWS')
db_tablename = os.getenv('DB_NAME')
ddb = boto3.resource('dynamodb', region_name = region_aws).Table(db_tablename)

def lambda_handler(event, context):
    short_id = event.get('short_id')
    
    try:
        item = ddb.get_item(Key={'short_id': short_id})
        long_url = item.get('Item').get('long_url')
        ddb.update_item(
            Key={'short_id': short_id},
            UpdateExpression='set hits = hits + :val',
            ExpressionAttributeValues={':val': 1}
        )
    
    except:
        return {
            'statusCode': 400,
            'body': 'short_id or url invalid in request.'
        }
    
    return {
        "statusCode": 302,
        "location": long_url
    }