locals {
  cluster_name                      = "sotw-cluster-${var.env}"
  database_username                 = data.aws_ssm_parameter.database_credentials_username.arn
  database_password                 = data.aws_ssm_parameter.database_credentials_password.arn
  database_host                     = data.aws_ssm_parameter.database_credentials_host.arn
  database_port                     = data.aws_ssm_parameter.database_credentials_port.arn
  database_db                       = data.aws_ssm_parameter.database_credentials_db.arn
  spotify_credentials_client_id     = data.aws_ssm_parameter.spotify_credentials_client_id.arn
  spotify_credentials_client_secret = data.aws_ssm_parameter.spotify_credentials_client_secret.arn
  domain_name                       = data.aws_ssm_parameter.domain_name.value
  api_version_tag                   = data.aws_ssm_parameter.ecs_api_version.value
  frontend_version_tag              = data.aws_ssm_parameter.ecs_frontend_version.value
  nginx_version_tag                 = data.aws_ssm_parameter.ecs_nginx_version.value
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
      target_capacity           = 100
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


  volume {
    name = "certificate-volume"
    # configure_at_launch = false


    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.certbot_efs.id
      transit_encryption = "ENABLED"
    }
  }

  container_definitions = jsonencode([
    {
      name = var.backend_container_name
      // TODO: REPLACE THIS WITH REAL ECS
      image     = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/sotw-api-repo-${var.env}:${local.api_version_tag}"
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
        valueFrom = "${local.database_host}"
        }, {
        name      = "DB_USER",
        valueFrom = "${local.database_username}"
        }, {
        name      = "DB_PASSWORD",
        valueFrom = "${local.database_password}"
        }, {
        name      = "DB_PORT",
        valueFrom = "${local.database_port}"
        },
        {
          name      = "DB_NAME",
          valueFrom = "${local.database_db}"
        },
        {
          name      = "SPOTIFY_CLIENT_ID",
          valueFrom = "${local.spotify_credentials_client_id}"
        },
        {
          name      = "SPOTIFY_CLIENT_SECRET",
          valueFrom = "${local.spotify_credentials_client_secret}"
        },
      ],
      environment = [
        { name = "DB_SCHEME", value = "cockroachdb" },
        { name = "BACKEND_CORS_ORIGINS", value = "[\"http://127.0.0.1:8000\", \"http://127.0.0.1:8080\"]" },
        { name = "COOKIE_SECURE_SETTING", value = "TRUE" },
        { name = "COOKIE_SAMESITE_SETTING", value = "none" }, # address before rolling out
        { name = "SMTP_FROM", value = "${var.email_user}@${local.domain_name}" },
        { name = "SMTP_FROM_NAME", value = var.email_user_from_name },
        { name = "REGISTRATION_VERIFICATION_URL", value = "https://${local.domain_name}/${var.registration_verification_endpoint}" },
        { name = "EMAIL_CHANGE_VERIFICATION_URL", value = "https://${local.domain_name}/${var.email_change_verification_endpoint}" },
        { name = "PASSWORD_RESET_VERIFICATION_URL", value = "https://${local.domain_name}/${var.password_reset_verification_endpoint}" },
        { name = "SPOTIFY_CALLBACK_URI", value = "https://${local.domain_name}/" },
        { name = "SEND_REGISTRATION_EMAILS", value = var.send_registration_emails },
        { name = "SHARE_TOKEN_EXPIRE_MINUTES", value = var.invite_token_expire_minutes },
        { name = "ACCESS_TOKEN_EXPIRE_MINUTES", value = var.access_token_expire_minutes },
        { name = "SESSION_COOKIE_EXPIRE_SECONDS", value = var.session_cookie_expire_seconds },
      ],
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8000/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
    },
    {
      name              = var.frontend_container_name
      image             = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/sotw-frontend-repo-${var.env}:${local.frontend_version_tag}"
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
      linuxParameters = {
        maxSwap    = 5120
        swappiness = 10
      }
      environment = [
        { name = "VITE_HOSTNAME", value = "https://${local.domain_name}/" },
        { name = "VITE_API_HOSTNAME", value = "https://${local.domain_name}/" },
        { name = "VITE_SPOTIFY_CALLBACK_URI", value = "https://${local.domain_name}/" },
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 240
      }
    },
    {
      name = var.proxy_container_name
      // TODO: REPLACE THIS WITH REAL ECS
      image  = "${var.account_id}.dkr.ecr.us-east-1.amazonaws.com/sotw-nginx-repo-${var.env}:${local.nginx_version_tag}"
      memory = 64

      essential = true
      portMappings = [
        {
          hostPort      = 80
          containerPort = 80
          protocol      = "tcp"
        },
        {
          hostPort      = 443
          containerPort = 443
          protocol      = "tcp"
        },
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
      environment = [
        { name = "DOMAIN_NAME", value = local.domain_name },
      ]
      mountPoints = [
        {
          sourceVolume  = "certificate-volume"
          containerPath = "/etc/letsencrypt"
          readOnly      = false
        }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
    },
    {
      name              = "certbot"
      image             = "certbot/dns-route53"
      essential         = false
      memoryReservation = 32
      command = [
        "certonly",
        "--dns-route53",
        "--agree-tos",
        "-n",
        "-m ${data.aws_ssm_parameter.lets_encrypt_email.value}",
        "-d ${local.domain_name},www.${local.domain_name}"
      ]
      dependsOn = [
        {
          containerName = var.proxy_container_name
          condition     = "START"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "ecs/certbot",
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = local.cluster_name
          awslogs-create-group  = "true"
        }
      }
      mountPoints = [
        {
          sourceVolume  = "certificate-volume"
          containerPath = "/etc/letsencrypt"
          readOnly      = false
        }
      ]

    },
  ])
}

resource "aws_ecs_service" "this" {
  name            = "sotw-ecs-service-${var.env}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count_sotw_ecs_tasks // TODO: REVISIT THIS BEFORE DEPLOYING FOR REAL
  force_new_deployment = false

  placement_constraints {
    type = "distinctInstance"
  }

  triggers = {
    redeployment = plantimestamp()
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 100
  }
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  depends_on = [aws_autoscaling_group.ecs_asg]
}