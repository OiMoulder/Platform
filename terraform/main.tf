resource "aws_lambda_function" "upload_lambda" {
  function_name = "uploadHandler"
  runtime       = "nodejs22.x"
  handler       = "index.handler"
  filename      = "lambda.zip"
  role          = aws_iam_role.lambda_exec.arn
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.content_bucket.bucket
    }
  }
}

resource "aws_apigatewayv2_api" "upload_api" {
  name          = "UploadAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.upload_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.upload_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "upload_route" {
  api_id    = aws_apigatewayv2_api.upload_api.id
  route_key = "POST /generate-upload-url"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.upload_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_s3_bucket" "content_bucket" {
  bucket = "platform-uploads"
  acl    = "private"
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.upload_api.api_endpoint
}