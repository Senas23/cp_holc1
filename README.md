# cp_holc1
Check Point HOLC1 - AWS High Available Drupal Site v2.2

## Idea
This project was created from the HOLC1 training material.
The idea was to code in IaC language to convert manual tasks into code.
It's alot faster and more efficient to create parts of lab with IaC at your available time.

## Requirements
Create AWS User with API access.

`terraform` - Version >=0.12

## Usage

```
git clone https://github.com/Senas23/cp_holc1.git
```
Create `terraform.tfvars` with:
```
drupalkey = {
  name = "drupalkey"
  hash = "<YOUR SSH PUB KEY e.g. from ~/.ssh/id_rsa.pub>"
}
```
```
export AWS_ACCESS_KEY_ID=<ACCESS KEY>
export AWS_SECRET_ACCESS_KEY=<SECRET KEY>
```
```
terraform init && terraform plan && terraform apply
```
