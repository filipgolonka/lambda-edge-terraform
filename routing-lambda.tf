data "archive_file" "routing" {
  type        = "zip"
  source_file = "src/lambda/routing/index.js"
  output_path = "dist/routing.zip"
}

resource "aws_lambda_function" "routing" {
  filename         = data.archive_file.routing.output_path
  source_code_hash = data.archive_file.routing.output_base64sha256

  function_name = "routing"
  description   = "Rewrites uris"
  handler       = "index.handler"
  publish       = true
  role          = aws_iam_role.routing.arn
  runtime       = "nodejs10.x"
  memory_size   = 128
  timeout       = 3
}

data "aws_iam_policy_document" "routing" {
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

resource "aws_iam_role" "routing" {
  assume_role_policy   = data.aws_iam_policy_document.routing.json
  description          = "Role for routing lambda function"
  name                 = "lambda-routing-role-khky711l"
  path                 = "/service-role/"
  max_session_duration = 3600
}

/* keep in mind that logs are written to the respective region, not always to us-east-1 */
resource "aws_cloudwatch_log_group" "routing" {
  name              = "/aws/lambda/${aws_lambda_function.routing.function_name}"
  retention_in_days = 14
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.routing.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
