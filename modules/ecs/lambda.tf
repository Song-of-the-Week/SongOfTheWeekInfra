resource "aws_lambda_function" "eip_assignment_function" {
  function_name = "EIPAssignmentFunction"
  runtime       = "nodejs20.x"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "index.handler"
  timeout       = 60

  filename         = "lambda.zip" # Path to your zipped Lambda code
  source_code_hash = filebase64sha256("lambda.zip")
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.eip_assignment_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.eip_assignment_function.arn
}

resource "aws_lambda_permission" "sns_invoke_permission" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.eip_assignment_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.eip_assignment_topic.arn
}

output "eip_assignment_lambda_function" {
  value = aws_lambda_function.eip_assignment_function.id
}

resource "aws_sns_topic" "eip_assignment_topic" {
  name = "EIPAssignmentTopic"
}