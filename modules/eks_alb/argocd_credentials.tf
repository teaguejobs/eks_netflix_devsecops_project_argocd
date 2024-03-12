resource "null_resource" "get_argocd_admin_password" {
  provisioner "remote-exec" {
    inline = [
      "ssh -o StrictHostKeyChecking=no -i \"web-ec2.pem\" ec2-user@${data.aws_instance.eks_netflix.private_ip} \"${var.null_resource_get_argocd_admin_password_remote_exec_inline}\""
    ]
  
  # provisioner "file" {
  #   source      = "get_argocd_admin_password.sh"
  #   destination = "/tmp/get_argocd_admin_password.sh"
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /tmp/get_argocd_admin_password.sh",
  #     "/tmp/get_argocd_admin_password.sh args",
  #   ]
  # }

  connection {
    type        = var.null_resource_get_argocd_admin_password_connection_type # "ssh"
    user        = var.null_resource_get_argocd_admin_password_connection_user # "your_ssh_user"
    private_key = file(var.null_resource_get_argocd_admin_password_connection_private_key)
    host        = data.aws_instance.bastion.public_ip
    # insecure = true
    
    }
  }
}

resource "null_resource" "output_argocd_admin_password" {
  provisioner "remote-exec" {
    inline = [
      # var.null_resource_output_argocd_admin_password_remote_exec_inline # echo $ARGO_PWD
      "ssh -o StrictHostKeyChecking=no -i \"web-ec2.pem\" -y ec2-user@${data.aws_instance.eks_netflix.private_ip} \"${var.null_resource_output_argocd_admin_password_remote_exec_inline}\""
    ]
  connection {
    type        = var.null_resource_output_argocd_admin_password_connection_type # "ssh"
    user        = var.null_resource_output_argocd_admin_password_connection_user # "your_ssh_user"
    private_key = file(var.null_resource_output_argocd_admin_password_connection_private_key)
    host        = data.aws_instance.bastion.public_ip
    }
  }

  depends_on = [null_resource.get_argocd_admin_password]
}

resource "null_resource" "force_provisioner_get_password" {
  triggers = {
    always_run = timestamp()
  }

  depends_on = [null_resource.get_argocd_admin_password]
}


resource "null_resource" "force_provisioner_output_password" {
  triggers = {
    always_run = timestamp()
  }

  depends_on = [null_resource.output_argocd_admin_password]
}
