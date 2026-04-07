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
	"long_url": "https://www.google.com/search?q=test"
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

### Testing via Insomnia/Postman

<img width="712" height="580" alt="Image" src="https://github.com/user-attachments/assets/2df3f063-0665-405e-aaf8-e3fa8f147f9c" />

<img width="713" height="747" alt="image" src="https://github.com/user-attachments/assets/2a77efe8-ed0b-4ad9-b5e2-8a84b5456926" />


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
