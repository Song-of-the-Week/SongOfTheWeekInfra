# SongOfTheWeekInfra
AWS Infrastructure for the Song of the Week Project

# Setup
`make install`

## Configure Credentials in AWS
For now, create an access key for the `terraform` IAM user. (We will make this better later)

`export AWS_ACCESS_KEY_ID=<access key>`
`export AWS_SECRET_ACCESS_KEY_ID=<secret access key>`

## Configure Credentials for Azure
* Authenticate to the Azure account
* Follow `Authenticate using the Azure CLI` (here)[https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-build#authenticate-using-the-azure-cli]

# Manual Setup Required (Ugh)
In the future these might be CloudFormation templates!

* Create an S3 bucket - call it something smart

* (EC2 ECS Role Creation)[https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html] (used to exist by default)

* Manually generate key pair for ECS EC2:
    * `ssh-keygen`, call it whatever you want, no password
    * Ensure you `terragrunt apply` on `deployments/<env>/secrets
    * Manually upload the secrets to the public and private secrets

* Manually register domain in Route53. You will need to access that in the `network/r53.tf` file
 * Add this domain to Systems Manager Parameter store at `/route53/domain`

* Manually register your AWS SES domain. Place it in `/email/send-from-address `as a string in Systems Manager Parameter Store.

* For CodeBuild, you need to provide an access token for GitHub. This can be any GitHub user, but we highly recommend creating an account exclusively for programmatic access. Create it (here)[https://github.com/settings/tokens?type=beta] and add the value to `/github/token` as a string.

* You must manually add your Spotify Client ID and Secret to `spotify/credentials` by filling out `clientId` and `clientSecret` in a JSON format.

* For CodeBuild, you must complete the CodeBuild GitHub connection (here)[https://us-east-2.console.aws.amazon.com/codesuite/settings/connection]