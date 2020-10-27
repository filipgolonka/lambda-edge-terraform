# lambda-edge-terraform

Code used during presentation on AWS User Group Krakow #50 meetup

## Usage

* run `terraform init`
* run `terraform plan` in order to see the changes
* run `terraform apply` in order to apply changes

Optionally you can use `terraform plan -out tfplan` and `terraform apply tfplan` in order to make sure you are applying the plan described by the first command.

In order to unit  test Lambdas locally, run `npm install` and then run `npm test`. Optionally, you can run it in watch mode: `npm test -- --watch`
