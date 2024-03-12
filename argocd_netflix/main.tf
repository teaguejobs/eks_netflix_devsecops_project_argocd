module "argocd_netflix" {
  source = ".././modules/argocd_netflix"

  null_resource_argocd_ready_remote_exec_inline         = var.null_resource_argocd_ready_remote_exec_inline
  null_resource_wait_for_argocd_connection_type         = var.null_resource_wait_for_argocd_connection_type
  null_resource_wait_for_argocd_connection_user         = var.null_resource_wait_for_argocd_connection_user
  null_resource_wait_for_argocd_connection_private_key  = "${path.module}/web-ec2.pem"
  argocd_application_netflix_metadata_name              = var.argocd_application_netflix_metadata_name
  argocd_application_netflix_metadata_namespace         = var.argocd_application_netflix_metadata_namespace
  argocd_application_netflix_spec_project_name          = var.argocd_application_netflix_spec_project_name
  argocd_application_netflix_spec_source                = var.argocd_application_netflix_spec_source
  argocd_application_netflix_spec_source_directory      = var.argocd_application_netflix_spec_source_directory
  argocd_application_netflix_spec_destination           = var.argocd_application_netflix_spec_destination
  argocd_application_netflix_spec_sync_policy           = var.argocd_application_netflix_spec_sync_policy
  argocd_application_netflix_spec_sync_policy_automated = var.argocd_application_netflix_spec_sync_policy_automated
  # null_resource_get_argocd_admin_password_remote_exec_inline = var.null_resource_get_argocd_admin_password_remote_exec_inline
}