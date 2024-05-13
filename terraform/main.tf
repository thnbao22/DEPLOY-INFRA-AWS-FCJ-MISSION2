# Define our modules
module "Networking" {
  source = "../modules/Networking"
  cidr_block = "10.10.0.0/16"
}

module "Compute" {
  source              = "../modules/Compute"
  instance_type       = "t2.micro"
  image_id            = "ami-04f73ca9a4310089f"
  keypair_name        = "workshop-keypair-2"
  web_server_sg_id    = module.Networking.public_sg_id
  public_subnet_1_id  = module.Networking.public_subnet_1_id
  public_subnet_2_id  = module.Networking.public_subnet_2_id
  alb_tg_arn          = module.LoadBalancing.alb_tg_arn
}

module "LoadBalancing" {
  source                = "../modules/LoadBalancing"
  one_tier_vpc_id       = module.Networking.vpc_id
  public_subnet_1_id    = module.Networking.public_subnet_1_id
  public_subnet_2_id    = module.Networking.public_subnet_2_id
  port                  = 80
  protocol              = "HTTP"
  alb_security_group_id = module.Networking.alb_sg_id
}