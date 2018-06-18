# for dealing with aws elasticbeanstalk
# needs the aws cli and jq

eb_describe() {
  aws elasticbeanstalk describe-environments --application-name "$APPLICATION_NAME" --environment-names "$ENVIRONMENT_NAME"
}

environment_status() {
  echo "$(eb_describe)" | jq -r .Environments[0].Status
}

environment_health() {
  echo "$(eb_describe)" | jq -r .Environments[0].Health
}

environment_version() {
  echo "$(eb_describe)" | jq -r .Environments[0].VersionLabel
}

environment_cname() {
  echo "$(eb_describe)" | jq -r .Environments[0].CNAME
}
