# SongOfTheWeekInfra
AWS Infrastructure for the Song of the Week Project

# Setup
`make install`


## Configure Credentials in AWS
For now, create an access key for the `terraform` IAM user. (We will make this better later)

### Set Defaults
We recommend you configure different profiles for credentials for each environment under `~/.aws/credentials`

This will look something like
```
[sotw-terraform]
aws_access_key_id = AKIAWXXXXXXXXXX
aws_secret_access_key = xxxxxxxxxxxxxxxxxxxxxxxx

[sotw-terraform-dev]
aws_access_key_id = AKIAWXXXXXXXXXX
aws_secret_access_key = xxxxxxxxxxxxxxxxxxxxxxxx
```

To use these profiles, simply `AWS_PROFILE=sotw-terraform terragrunt plan`. Ensure you do not have any default AWS credentials in your environment.

```
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY
```

These should both return nothing.

## Configure Credentials for Azure (Deprecated)
* Authenticate to the Azure account
* Follow `Authenticate using the Azure CLI` (here)[https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-build#authenticate-using-the-azure-cli]

# Manual Setup Required (Ugh)
In the future these might be CloudFormation templates!

## Terraform S3 Backend Configuration
* Create an S3 bucket - call it something smart
* Add this to the root.hcl of your environment `remote_state` -> `config` -> `bucket`

## ECS Configuration

* (EC2 ECS Role Creation)[https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html] (used to exist by default)

* Manually generate key pair for ECS EC2:
    * `ssh-keygen`, call it whatever you want, no password
    * Ensure you `terragrunt apply` on `deployments/<env>/secrets
    * Manually upload the secrets to the public and private secrets

## Register Domains and Certificates
* Manually register domain in Route53. You will need to access that in the `network/r53.tf` file
 * Add this domain to Systems Manager Parameter store at `/route53/domain`

* Manually register for an AWS ACM Certificate for this domain. TODO: This should be configured as a parameter in parameter store in the future.

Then, add to the terragrunt.hcl in your network directory under the proper environment like so:

 ```
    inputs = {
        domain_name = "mydomain.com"
        acm_cert_id = "839b2ee5-94dc-4b3f-8c6c-2af5f2023c6a"
    }
 ```
## Set Up A Database
We use (cockroachlabs)[cockroachlabs.cloud]. Configure a database there, and save the password to `/database/credentials` under password in Secrets Manager.

## Configure Simple Email Service
We use SES for email verification.
* Manually register your AWS SES domain. Place it in `/email/send-from-address` as a string in Systems Manager Parameter Store.
* Follow the prompts in the SES console to add the DNS records to Route53 for the domain you registerd.

## GitHub Integration into CodeBuild and CodePipeline
* For CodeBuild, you need to provide an access token for GitHub. This can be any GitHub user, but we highly recommend creating an account exclusively for programmatic access. Create it (here)[https://github.com/settings/tokens?type=beta] and add the value to `/github/token` as a string.

* To pull source into CodePipleline must complete the CodeBuild GitHub connection (here)[https://us-east-2.console.aws.amazon.com/codesuite/settings/connection]


## Spotify Connection
* You must manually add your Spotify Client ID and Secret to `spotify/credentials` by filling out `clientId` and `clientSecret` in a JSON format.


## ECR Prerequisites

Our current setup requires an intial set of images to exist in ECR at the specified repositores. Build the app for production from the application repo using `make ENV=prod docker-build` in that repository, then push the images to the respective repos. You will not have to do this once the application has been built initially. 

## Let's Encrypt

You need to add the email you want registered with your Let's Encrypt SSL certificate in Parameter Store at `/secrets/lets-encrypt-email`