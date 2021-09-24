resource "aws_lb_target_group" "drupalsite" {
  name        = "Drupalsite"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.drupalvpc.id
  health_check {
    path    = "/"
    matcher = "200"
  }

  tags = {
    Name = "Drupal TG"
  }
}

resource "aws_lb" "drupalsite" {
  name               = "Drupalsite"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.drupallbsg.id]
  subnets            = aws_subnet.natsub.*.id
  #enable_deletion_protection = true

  tags = {
    Name = "Drupal Site"
  }
}

resource "aws_lb_listener" "drupal" {
  load_balancer_arn = aws_lb.drupalsite.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.drupalsite.arn
  }
}
