#----- symbiosis/dns.tf -----#

data "aws_route53_zone" "selected" {
  name = "tbicommons.io"
}

resource "aws_route53_record" "www" {
  name    = "www"
  type    = "A"
  zone_id = data.aws_route53_zone.selected.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_lb.lb.dns_name
    zone_id                = aws_lb.lb.zone_id
  }
}

