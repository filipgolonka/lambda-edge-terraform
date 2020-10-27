data "archive_file" "api-docs" {
  type        = "zip"
  source_file = "src/lambda/api-docs/index.js"
  output_path = "dist/api-docs.zip"
}

resource "aws_lambda_function" "api-docs" {
  filename         = data.archive_file.api-docs.output_path
  source_code_hash = data.archive_file.api-docs.output_base64sha256

  function_name = "api-docs"
  description   = "Guard for API docs"
  handler       = "index.handler"
  publish       = true
  role          = aws_iam_role.api-docs.arn
  runtime       = "nodejs10.x"
  memory_size   = 128
  timeout       = 3
}

data "aws_iam_policy_document" "api-docs" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = [
        "edgelambda.amazonaws.com",
        "lambda.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "api-docs" {
  assume_role_policy   = data.aws_iam_policy_document.api-docs.json
  description          = "Role for api-docs lambda function"
  name                 = "lambda-api-docs-role-khky711l"
  path                 = "/service-role/"
  max_session_duration = 3600
}

/* keep in mind that logs are written to the respective region, not always to us-east-1 */
resource "aws_cloudwatch_log_group" "api-docs" {
  name              = "/aws/lambda/${aws_lambda_function.api-docs.function_name}"
  retention_in_days = 14
}

resource "aws_iam_role_policy_attachment" "api_docs_lambda_logs" {
  role       = aws_iam_role.api-docs.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
