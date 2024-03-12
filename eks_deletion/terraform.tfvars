null_resource_patch_ingress_remote_exec_inline = "sudo -u ec2-user /usr/bin/kubectl patch ingress argocd-server -n argocd -p '{\\\"metadata\\\":{\\\"finalizers\\\":[]}}' --type=merge\""
null_resource_patch_ingress_connection_type    = "ssh"
null_resource_patch_ingress_connection_user    = "ec2-user"