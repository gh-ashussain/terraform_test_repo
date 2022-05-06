# Audit Service AWS resources

# How to run Locally

1) saml2aws login -a <profile_name>
2) switch to terraform directory <cd terraform/>
3) terraform init -backend-config=environments/dev/remote-backend.properties
4) terraform validate
5) terraform plan -out tfplan.out -var-file=environments/dev/terraform.tfvars
6) terraform apply tfplan.out