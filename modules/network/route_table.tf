resource "aws_route_table" "route_table" {
 vpc_id = aws_vpc.main.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.internet_gateway.id
 }
}



resource "aws_route_table_association" "subnet_1b_route" {
 subnet_id      = aws_subnet.ecs_1b.id
 route_table_id = aws_route_table.route_table.id
}



resource "aws_route_table_association" "subnet_1a_route" {
 subnet_id      = aws_subnet.ecs_1a.id
 route_table_id = aws_route_table.route_table.id
}