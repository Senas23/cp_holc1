resource "aws_autoscaling_group" "drupal" {
  name                = "Drupal Site ASG"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = [for v in aws_subnet.drupalsub[*] : v.id]
  target_group_arns   = [aws_lb_target_group.drupalsite.arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.drupal.id
    version = "$Latest"
  }

  enabled_metrics = ["GroupDesiredCapacity", "GroupInServiceCapacity",
    "GroupPendingCapacity", "GroupMinSize", "GroupMaxSize", "GroupInServiceInstances",
    "GroupPendingInstances", "GroupStandbyInstances", "GroupStandbyCapacity",
    "GroupTerminatingCapacity", "GroupTerminatingInstances", "GroupTotalCapacity",
    "GroupTotalInstances", "GroupAndWarmPoolDesiredCapacity", "GroupAndWarmPoolTotalCapacity",
    "WarmPoolDesiredCapacity", "WarmPoolMinSize", "WarmPoolPendingCapacity",
  "WarmPoolTerminatingCapacity", "WarmPoolTotalCapacity", "WarmPoolWarmedCapacity"]
}

resource "aws_cloudwatch_metric_alarm" "drupal" {
  alarm_name          = "Step-Scaling-AlarmHigh-AddCapacity"
  alarm_description   = "highCPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "4"
  datapoints_to_alarm = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"
  alarm_actions       = [aws_autoscaling_policy.drupal.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.drupal.name
  }
}

resource "aws_autoscaling_policy" "drupal" {
  name                   = "Step-Scaling-AlarmHigh-AddCapacity"
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.drupal.name

  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
  }
}
