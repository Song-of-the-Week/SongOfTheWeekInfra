# SongOfTheWeekInfra
AWS Infrastructure for the Song of the Week Project

# Setup
`make install`

## Configure Credentials in AWS
For now, create an access key for the `terraform` IAM user. (We will make this better later)

`export AWS_ACCESS_KEY_ID=<access key>`
`export AWS_SECRET_ACCESS_KEY_ID=<secret access key>`

# Manual Setup Required (Ugh)
In the future these might be CloudFormation templates!

* Create an S3 bucket - call it something smart

* (EC2 ECS Role Creation)[https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html] (used to exist by default)

* Manually generate key pair for ECS EC2:
    * `ssh-keygen`, call it whatever you want, no password
    * Ensure you `terragrunt apply` on `deployments/<env>/secrets
    * Manually upload the secrets to the public and private secrets