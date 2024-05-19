resource "aws_ecs_cluster" "this" {
  name = "sotw-cluster-${var.env}"
}

resource "aws_ecs_capacity_provider" "this" {
  name = "sotw-ecs-capacity-provider-${var.env}"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 3
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = [aws_ecs_capacity_provider.this.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.this.name
  }
}

resource "aws_ecs_task_definition" "this" {
  family             = "sotw-ecs-task-definition-${var.env}"
  network_mode       = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  cpu                = 256

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name = "dockergs"
      // TODO: REPLACE THIS WITH REAL ECS
      image     = "public.ecr.aws/b5a8n3h2/sotw-prod-temp:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "sotw-ecs-service-${var.env}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 2

  network_configuration {
    subnets         = [data.aws_ssm_parameter.subnet_1a_id.value, data.aws_ssm_parameter.subnet_1b_id.value]
    security_groups = [data.aws_ssm_parameter.sg_id.value]
  }

  force_new_deployment = true

  placement_constraints {
    type = "distinctInstance"
  }

  triggers = {
    redeployment = timestamp()
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 100
  }

  load_balancer {
    target_group_arn = data.aws_ssm_parameter.tg_id.value
    container_name   = "dockergs"
    container_port   = 80
  }

  depends_on = [aws_autoscaling_group.ecs_asg]
}