data "archive_file" "waf" {
  type        = "zip"
  source_file = "src/lambda/waf/index.js"
  output_path = "dist/waf.zip"
}

resource "aws_lambda_function" "waf" {
  filename         = data.archive_file.waf.output_path
  source_code_hash = data.archive_file.waf.output_base64sha256

  function_name = "waf"
  description   = "Simple WAF"
  handler       = "index.handler"
  publish       = true
  role          = aws_iam_role.waf.arn
  runtime       = "nodejs10.x"
  memory_size   = 128
  timeout       = 3
}

data "aws_iam_policy_document" "waf" {
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

resource "aws_iam_role" "waf" {
  assume_role_policy   = data.aws_iam_policy_document.waf.json
  description          = "Role for WAF lambda function"
  name                 = "lambda-waf-role-khky711l"
  path                 = "/service-role/"
  max_session_duration = 3600
}

/* keep in mind that logs are written to the respective region, not always to us-east-1 */
resource "aws_cloudwatch_log_group" "waf" {
  name              = "/aws/lambda/${aws_lambda_function.waf.function_name}"
  retention_in_days = 14
}

resource "aws_iam_role_policy_attachment" "waf_lambda_logs" {
  role       = aws_iam_role.waf.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
