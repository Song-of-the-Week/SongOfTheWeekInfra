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