# DataDog AWS Integration

An AWS IAM Role and Policy to provide the permissions required by DataDog for the AWS Integration documented at https://docs.datadoghq.com/integrations/amazon_web_services/

## Usage

### DataDog Infrastructure Integration
Retrieve your AWS External ID from the Integration setup page and set `datadog_aws_external_id` to that value.

### DataDog Logging

In order to configure the logging, you will need a pro or enterprise account, and you'll need to ensure that the [DataDog Lambda code](https://github.com/dataDog/datadog-serverless-functions/tree/master/aws/logs_monitoring) is packaged into a zip file in a directory named "artefacts" under the directory that you will run the terraform commands from:

```bash
.
├── artefacts
│   ├── aws-logs-monitoring.zip
│   ├── aws-rds-enhanced-monitoring.zip
```

Deploy your code to setup the various KMS components, and then generate your encrypted DataDog API payload for the Lambda by running `aws --region=eu-west-2 kms encrypt --key-id alias/datadog_api_key --plaintext '<YOUR API KEY'`.

Use the output of that command to set the `dd\_logging\_kms\_encrypted\_keys` value, and re-apply the Terraform - this will reconfigure the Lambda to use the correct values for the keys and you should start to see logs streaming into DataDog.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| datadog\_aws\_external\_id | The external ID from the AWS Integration Setup Screen in DataDog | string | - | yes |
| dd\_logging\_kms\_encrypted\_keys | The Base64-encoded output from the AWS KMS Encryption command | string | - | yes |

## Copyright

This module is released by Mockingbird Consulting Ltd under the MIT License.
All content remains the copyright of Mockingbird Consulting © 2018
For more information on Mockingbird Consulting, please visit www.mockingbirdconsulting.co.uk
