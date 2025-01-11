resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name = "vpclink-${var.env}"

  security_group_ids = [aws_security_group.vpc_link.id]
  subnet_ids         = [aws_subnet.ecs_1a.id, aws_subnet.ecs_1b.id]
}
