output "vpc_id" {
  value = aws_vpc.one-tier-vpc.id
}
output "public_subnet_1_id" {
  value = aws_subnet.public_subnet_1.id
}
output "public_subnet_2_id" {
  value = aws_subnet.public_subnet_2.id
}
output "public_sg_id" {
  value = aws_security_group.one_tier_public_sg.id
}
output "alb_sg_id" {
  value = aws_security_group.one_tier_alb_sg.id
}
