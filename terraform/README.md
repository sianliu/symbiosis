## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.13.5 |
| aws | ~> 3.20.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.20.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| db_username | The username to the RDS instance. | `string` | n/a | yes |
| db_password | The password to the RDS instance. | `string` | `"aws/ebs"` | no |

## Outputs

| Name | Description |
|------|-------------|
| lb_ip | Outputs the dns address of the application load balancer |
 