-- Cài đặt S3 credentials và endpoint
SET s3_endpoint='adventureworksseaweedfs:8333';
SET s3_access_key_id='admin';
SET s3_secret_access_key='admin';
SET s3_use_ssl=false;
SET s3_url_style='path';
SET s3_region='us-east-1';

-- Load extensions nếu chưa có
INSTALL httpfs;
LOAD httpfs;
INSTALL aws;
LOAD aws;