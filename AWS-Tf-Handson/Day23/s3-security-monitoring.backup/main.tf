module "sns_security" {
  source               = "./modules/sns_security"
  security_alert_email = var.security_alert_email
}

module "log_ingest_s3" {
  source                = "./modules/log_ingest_s3"
  monitored_bucket_name = var.monitored_bucket_name
}

module "security_metrics" {
  source         = "./modules/security_metrics"
  log_group_name = module.log_ingest_s3.log_group_name
}

module "security_alarms" {
  source                 = "./modules/security_alarms"
  metric_namespace       = module.security_metrics.metric_namespace
  denied_metric_name     = module.security_metrics.denied_metric_name
  restricted_metric_name = module.security_metrics.restricted_metric_name
  sns_topic_arn          = module.sns_security.sns_topic_arn
}
