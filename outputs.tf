output "account" {
  value = {
    id     = data.aws_caller_identity.current.account_id
    region = var.region
  }
  description = "A map of AWS account attributes: id, region."
}

output "vpc" {
  value = {
    // NOTE: these are declared here -
    // https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc
    id   = data.aws_vpc.vpc.id
    arn  = data.aws_vpc.vpc.arn
    cidr = data.aws_vpc.vpc.cidr_block
    azs  = data.aws_availability_zones.available.names
    # replaces this next line - overall not necessary
    # azs  = data.aws_vpc.vpc.azs

    // ensure the data resource will actually hand us this
    private_subnet_cidr_blocks = local.subnets.private.cidrs
    private_subnet_ids         = local.subnets.private.ids

    public_subnet_cidr_blocks = local.subnets.public.cidrs
    public_subnet_ids         = local.subnets.public.ids
    runner_subnet_id          = local.subnets.runner.ids[0]
    runner_subnet_cidr        = local.subnets.runner.cidrs[0]

    default_security_group_id = data.aws_security_group.default.id
  }
  description = "A map of vpc attributes: name, id, cidr, azs, private_subnet_cidr_blocks, private_subnet_ids, public_subnet_cidr_blocks, public_subnet_ids, default_security_group_id."
}

output "ecr" {
  value = {
    repository_url  = module.ecr.repository_url
    repository_arn  = module.ecr.repository_arn
    repository_name = var.nuon_id
    registry_id     = module.ecr.repository_registry_id
    registry_url    = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
  }
  description = "A map of ECR attributes: repository_url, repository_arn, repository_name, registry_id, registry_url."
}


output "nuon_dns" {
  value = {
    enabled         = local.nuon_dns.enabled,
    public_domain   = local.nuon_dns.enabled ? module.nuon_dns[0].public_domain : { zone_id : "", name : "", nameservers : tolist([""]) }
    internal_domain = local.nuon_dns.enabled ? module.nuon_dns[0].internal_domain : { zone_id : "", name : "", nameservers : tolist([""]) }
    alb_ingress_controller = {
      enabled  = local.nuon_dns.enabled
      id       = local.nuon_dns.enabled ? module.nuon_dns[0].alb_ingress_controller.release.id : ""
      chart    = local.nuon_dns.enabled ? module.nuon_dns[0].alb_ingress_controller.release.chart : ""
      revision = local.nuon_dns.enabled ? module.nuon_dns[0].alb_ingress_controller.release.revision : ""
    }
    external_dns = {
      enabled  = local.nuon_dns.enabled
      id       = local.nuon_dns.enabled ? module.nuon_dns[0].external_dns.release.id : ""
      chart    = local.nuon_dns.enabled ? module.nuon_dns[0].external_dns.release.chart : ""
      revision = local.nuon_dns.enabled ? module.nuon_dns[0].external_dns.release.revision : ""
    }
    cert_manager = {
      enabled  = local.nuon_dns.enabled
      id       = local.nuon_dns.enabled ? module.nuon_dns[0].cert_manager.release.id : ""
      chart    = local.nuon_dns.enabled ? module.nuon_dns[0].cert_manager.release.chart : ""
      revision = local.nuon_dns.enabled ? module.nuon_dns[0].cert_manager.release.revision : ""
    }
    ingress_nginx = {
      enabled  = local.nuon_dns.enabled
      id       = local.nuon_dns.enabled ? module.nuon_dns[0].ingress_nginx.release.id : ""
      chart    = local.nuon_dns.enabled ? module.nuon_dns[0].ingress_nginx.release.chart : ""
      revision = local.nuon_dns.enabled ? module.nuon_dns[0].ingress_nginx.release.revision : ""
    }
  }
  description = "A map of Nuon DNS attributes: whether nuon.run has been enabled; AWS Route 53 details for the public_domain and internal_domain; metadata bout the helm charts the module installs on."
}
