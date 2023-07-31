locals {
  installation_command_for_each_dist = {
    centos = "sudo yum install -y python",
    rhel   = "sudo yum install -y python",
    ubuntu = "sudo apt-get install -y python",
    alpine = "sudo apk add --no-cache python3",
  }

  inventory_file_prefix = "${path.root}/.terraform/tmp/.ansible_hosts"

  set_envs_command = join(" ", [
    "export",
    join(" ", [
      for k, v in var.envs : "${k}=${v}"
    ]),
  ])
}

resource "random_id" "tmp" {
  byte_length = 8
}

resource "null_resource" "prepare_ansible" {
  provisioner "remote-exec" {
    connection {
      type        = var.connection.type
      user        = var.connection.user
      host        = var.connection.host
      private_key = file(var.connection.private_key_path)
    }
    inline = [
      local.installation_command_for_each_dist[var.distribution]
    ]
  }
}

resource "null_resource" "playbooks" {
  depends_on = [null_resource.prepare_ansible]
  for_each   = toset(var.playbooks)

  triggers = {
    policy_sha1    = "${sha1(file(each.value))}"
    inventory_file = "${local.inventory_file_prefix}.${random_id.tmp.hex}"
  }

  # Generate inventory file as temporary file
  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p $(dirname ${self.triggers.inventory_file})
      echo "[${random_id.tmp.hex}]" > ${self.triggers.inventory_file}
      echo "${var.connection.host}" >> ${self.triggers.inventory_file}
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
      ${local.set_envs_command}
      ansible-playbook ${each.value} \
        -i ${self.triggers.inventory_file} \
        -u ${var.connection.user} \
        --private-key ${var.connection.private_key_path}
    EOT
  }

  # Remove inventory file
  provisioner "local-exec" {
    command = "rm -f ${self.triggers.inventory_file}"
  }
}
