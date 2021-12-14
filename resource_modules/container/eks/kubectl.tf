resource "local_file" "kubeconfig" {
  content              = local.kubeconfig
  filename             = local.config_output_path
  file_permission      = "0644"
  directory_permission = "0755"
}

resource "null_resource" "wait_kubeconfig" {
  depends_on = [local_file.kubeconfig]

  provisioner "local-exec" {
    command     = "cp ${local.config_output_path} /home/loctran/.kube/config"
  }
}
