#----- symbiosis/outputs.tf -----#

output "lb_ip" {
  value = aws_lb.lb.dns_name
}