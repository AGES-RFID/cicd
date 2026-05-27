data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "lambda_sg" {
  name        = "${var.project_name}-lambda-sg-${var.environment}"
  description = "Security group for Backend Lambda"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-lambda-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_secrets_access" {
  name = "read-rds-secret"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Resource = aws_db_instance.postgres.master_user_secret[0].secret_arn
    }]
  })
}

data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = aws_db_instance.postgres.master_user_secret[0].secret_arn
}

locals {
  db_password = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)["password"]
}

resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.project_name}-artifacts-${var.environment}"
  force_destroy = var.environment != "production"
}

resource "aws_s3_bucket_lifecycle_configuration" "artifacts_lifecycle" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    id     = "cleanup-old-artifacts"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }
  }
}

output "artifacts_bucket_name" {
  value = aws_s3_bucket.artifacts.id
}

data "archive_file" "dummy_lambda" {
  type        = "zip"
  output_path = "${path.module}/dummy.zip"
  source {
    content  = "Initial placeholder"
    filename = "dummy.txt"
  }
}

resource "aws_lambda_function" "backend" {
  function_name = "${var.project_name}-backend-${var.environment}"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "provided.al2023"
  handler       = "bootstrap"
  timeout       = 15
  memory_size   = 512

  filename         = data.archive_file.dummy_lambda.output_path
  source_code_hash = data.archive_file.dummy_lambda.output_base64sha256

  vpc_config {
    subnet_ids         = data.aws_subnets.default.ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      ENVIRONMENT                           = var.environment
      DB_HOST                               = aws_db_instance.postgres.address
      DB_PORT                               = aws_db_instance.postgres.port
      DB_NAME                               = aws_db_instance.postgres.db_name
      DB_USER                               = aws_db_instance.postgres.username
      DB_SECRET_ARN                         = aws_db_instance.postgres.master_user_secret[0].secret_arn
      ConnectionStrings__Default            = "Host=${aws_db_instance.postgres.address};Port=${aws_db_instance.postgres.port};Database=${aws_db_instance.postgres.db_name};Username=${aws_db_instance.postgres.username};Password=${local.db_password};"
      DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "true"
      Cors__Origins__0                      = "*"
    }
  }

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_vpc_access,
    aws_iam_role_policy.lambda_secrets_access
  ]
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-api-${var.environment}"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.backend.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
