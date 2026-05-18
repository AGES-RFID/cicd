output "frontend_bucket_name" {
  description = "Nome do bucket S3 do Frontend"
  value       = aws_s3_bucket.frontend.id
}

output "frontend_cloudfront_url" {
  description = "URL pública do CloudFront"
  value       = "https://${aws_cloudfront_distribution.frontend_cdn.domain_name}"
}

output "backend_lambda_name" {
  description = "Nome da função Lambda"
  value       = aws_lambda_function.backend.function_name
}

output "backend_api_url" {
  description = "URL pública do API Gateway (Injetar no Frontend)"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}
