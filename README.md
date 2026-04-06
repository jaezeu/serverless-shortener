# Serverless URL Shortener (Terraform + AWS)

This project deploys a serverless URL shortener on AWS using Terraform.

## Architecture Diagram

![Image](https://github.com/user-attachments/assets/feab6f4b-4996-42f1-ba15-ce7b3d169ea0)

## What it does

- Creates short URLs with `POST /newurl`
- Redirects users with `GET /{shortid}`
- Stores mappings in DynamoDB
- Uses API Gateway and Lambda for fully managed compute and routing
- Uses Route 53 + ACM for a custom API domain
- Applies a WAF ACL to API Gateway

## Architecture

Core AWS services used:

- API Gateway (Regional)
- Lambda (create URL, retrieve URL)
- DynamoDB (`short_id` as partition key, `PAY_PER_REQUEST` billing)
- IAM role/policy for least-privilege Lambda access to DynamoDB
- Route 53 + ACM + API Gateway custom domain
- WAFv2 (IP allowlist pattern)

## Repository layout

- `apigateway.tf`: API resources, methods, integrations, deployment, stage
- `lambda.tf`: Lambda modules, runtime config, IAM role and policy modules
- `dynamodb.tf`: DynamoDB table definition
- `domain.tf`: ACM, API custom domain, base path mapping, Route 53 record
- `data.tf`: AWS account/region/Route53 lookups and IAM policy document
- `waf.tf`: Web ACL, logging, and API stage association
- `backend.tf`: Terraform S3 backend config
- `provider.tf`: AWS provider region
- `url-create-lambda/lambda_function.py`: Create short URL handler
- `url-retrieve-lambda/lambda_function.py`: Retrieve/redirect handler

## Prerequisites

- Terraform installed
- AWS credentials configured
- Route 53 hosted zone for your domain
- S3 bucket for Terraform remote state (or adjust backend strategy)

## Important configuration to update before deploy

This repo currently contains environment-specific values. Update these to your own environment:

- `provider.tf`
	- AWS region
- `backend.tf`
	- S3 backend bucket/key/region
- `data.tf`
	- `data "aws_route53_zone" "zone"` domain name
- `domain.tf`
	- ACM and API custom domain values
- `lambda.tf`
	- `APP_URL` environment variable used when generating short URLs

## Deploy

From the project root, run:

```bash
terraform init
terraform plan
terraform apply
```

## API contract

### Create short URL

- Method: `POST`
- Path: `/newurl`
- Request body:

```json
{
	"long_url": "https://example.com/search?q=helloworld"
}
```

- Success response:
	- Status: `200`
	- Body: short URL string

### Resolve short URL

- Method: `GET`
- Path: `/{shortid}`
- Success response:
	- Status: `302`
	- Redirect location returned from integration mapping

<img width="1168" alt="Screenshot 2022-11-23 at 10 55 30 PM" src="https://user-images.githubusercontent.com/48310743/203578413-eca72b35-395a-4736-a386-a340feddcc93.png">

<img width="726" alt="Screenshot 2022-11-23 at 11 02 52 PM" src="https://user-images.githubusercontent.com/48310743/203579453-810f0867-9d3c-4bb6-8b45-9100d1907059.png">

<img width="1185" alt="Screenshot 2022-11-23 at 10 56 33 PM" src="https://user-images.githubusercontent.com/48310743/203578678-573fb534-c563-4e82-a366-cedea4881d27.png">

<img width="742" alt="Screenshot 2022-11-23 at 10 58 03 PM" src="https://user-images.githubusercontent.com/48310743/203578855-e430020a-33db-41b6-9a40-18db95683ed1.png">

## Notes on scalability and reliability

- Lambda scales with concurrent requests (subject to account quotas)
- API Gateway scales automatically
- DynamoDB on-demand mode is suitable for variable traffic patterns
- Managed AWS services reduce operational overhead and single-host risk

## Security notes

- Lambda execution role has scoped DynamoDB permissions
- API methods currently use `authorization = "NONE"`
- WAF configuration currently defaults to block and allows only an IP set
	- In the current `waf.tf`, the IP set is derived from your current public IP at apply time
	- If your IP changes, requests may be blocked until the ACL is updated/re-applied

## Quick verification after deploy

1. Call `POST /newurl` with a valid `long_url`
2. Confirm a new item exists in DynamoDB
3. Call `GET /{shortid}`
4. Confirm redirect works and `hits` increments

## Destroy

To remove all resources:

```bash
terraform destroy
```
