locals {
  cluster_name         = "sotw-cluster-${var.env}"
  database_credentials = data.aws_ssm_parameter.database_credentials.value
  spotify_credentials  = data.aws_ssm_parameter.spotify_credentials.value
  email_address        = data.aws_ssm_parameter.email_address.value
  domain_name          = data.aws_ssm_parameter.domain_name.value
  api_version_tag      = data.aws_ssm_parameter.ecs_api_version.value
  frontend_version_tag = data.aws_ssm_parameter.ecs_frontend_version.value
  nginx_version_tag    = data.aws_ssm_parameter.ecs_nginx_version.value
}

resource "aws_ecs_cluster" "this" {
  name = local.cluster_name
}

resource "aws_ecs_capacity_provider" "this" {
  name = "sotw-ecs-capacity-provider-${var.env}"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 50
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
  network_mode       = "bridge"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  cpu                = 320

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name = var.backend_container_name
      // TODO: REPLACE THIS WITH REAL ECS
      image = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/sotw-api-repo-${var.env}:${local.api_version_tag}"
      # cpu       = 128
      memory    = 128
      essential = true
      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "ecs/${var.backend_container_name}",
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = local.cluster_name
          awslogs-create-group  = "true"
        }
      },
      secrets = [{
        name      = "DB_HOST",
        valueFrom = "${local.database_credentials}:host::"
        }, {
        name      = "DB_USER",
        valueFrom = "${local.database_credentials}:username::"
        }, {
        name      = "DB_PASSWORD",
        valueFrom = "${local.database_credentials}:password::"
        }, {
        name      = "DB_PORT",
        valueFrom = "${local.database_credentials}:port::"
        },
        {
          name      = "DB_NAME",
          valueFrom = "${local.database_credentials}:db::"
        },
        {
          name      = "SPOTIFY_CLIENT_ID",
          valueFrom = "${local.spotify_credentials}:clientId::"
        },
        {
          name      = "SPOTIFY_CLIENT_SECRET",
          valueFrom = "${local.spotify_credentials}:clientSecret::"
        },
      ],
      environment = [
        { name = "DB_SCHEME", value = "cockroachdb" },
        { name = "BACKEND_CORS_ORIGINS", value = "[\"http://127.0.0.1:8000\", \"http://127.0.0.1:8080\"]" },
        { name = "COOKIE_SECURE_SETTING", value = "TRUE" },
        { name = "COOKIE_SAMESITE_SETTING", value = "none" }, # address before rolling out
        { name = "SMTP_FROM", value = "${var.email_user}@${local.email_address}" },
        { name = "SMTP_FROM_NAME", value = var.email_user_from_name },
        { name = "REGISTRATION_VERIFICATION_URL", value = "https://${local.domain_name}/${var.registration_verification_endpoint}" },
        { name = "EMAIL_CHANGE_VERIFICATION_URL", value = "https://${local.domain_name}/${var.email_change_verification_endpoint}" },
        { name = "PASSWORD_RESET_VERIFICATION_URL", value = "https://${local.domain_name}/${var.password_reset_verification_endpoint}" },
        { name = "SPOTIFY_CALLBACK_URI", value = "https://${local.domain_name}/" },
        { name = "SEND_REGISTRATION_EMAILS", value = var.send_registration_emails },
      ]
    },
    {
      name = var.frontend_container_name
      // TODO: REPLACE THIS WITH REAL ECS
      image = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/sotw-frontend-repo-${var.env}:${local.frontend_version_tag}"
      # cpu               = 128
      memoryReservation = 600
      essential         = true
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ],
      dependsOn = [{
        containerName = var.backend_container_name
        condition     = "START"
      }]
      command = ["npm", "run", "serve-prod"]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "ecs/${var.frontend_container_name}",
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = local.cluster_name
          awslogs-create-group  = "true"
        }
      },
      linuxParameters = {
        maxSwap    = 5120
        swappiness = 10
      }
      environment = [
        { name = "VUE_APP_HOSTNAME", value = "https://${local.domain_name}/" },
        { name = "VUE_APP_API_HOSTNAME", value = "https://${local.domain_name}/" },
        { name = "VUE_APP_SPOTIFY_CALLBACK_URI", value = "https://${local.domain_name}/" },
      ]
    },
    {
      name = var.proxy_container_name
      // TODO: REPLACE THIS WITH REAL ECS
      image = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/sotw-nginx-repo-${var.env}:${local.nginx_version_tag}"
      # cpu       = 64
      memory    = 64
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ],
      dependsOn = [
        {
          containerName = var.backend_container_name
          condition     = "START"
        },
        {
          containerName = var.frontend_container_name
          condition     = "START"
        },
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "ecs/${var.proxy_container_name}",
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = local.cluster_name
          awslogs-create-group  = "true"
        }
      },
      links = [
        var.frontend_container_name, var.backend_container_name
      ]
    },
  ])
}

resource "aws_ecs_service" "this" {
  name            = "sotw-ecs-service-${var.env}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1 // TODO: REVISIT THIS BEFORE DEPLOYING FOR REAL

  # network_configuration {
  #   subnets         = [data.aws_ssm_parameter.subnet_1a_id.value, data.aws_ssm_parameter.subnet_1b_id.value]
  #   security_groups = [data.aws_ssm_parameter.sg_id.value]
  # }

  force_new_deployment = false

  # placement_constraints {
  #   type = "distinctInstance"
  # }

  triggers = {
    redeployment = plantimestamp()
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 100
  }

  load_balancer {
    target_group_arn = data.aws_ssm_parameter.tg_id.value
    container_name   = "nginx"
    container_port   = 80
  }

  depends_on = [aws_autoscaling_group.ecs_asg]
}