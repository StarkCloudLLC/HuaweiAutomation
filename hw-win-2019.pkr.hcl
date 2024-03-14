packer {
  required_plugins {
    huawei = {
      version = ">= 1.0.0"
      source  = "github.com/huaweicloud/huaweicloud"
    }
  }
}

locals {
  timestamp = formatdate("MM-DD-YYYY", timestamp())
}

variable "access_key" {
  type    = string
  default = env("TF_VAR_ak")
}

variable "secret_key" {
  type      = string
  default   = env("TF_VAR_sk")
  sensitive = true
}

variable "region" {
  default = env("TF_VAR_region")
  type    = string
}

variable "source_image" {
  type    = string
  # Este ID es una imagen de Windows 2019 STD en mi cuenta
  default = "72ec580b-875d-499f-b472-cca7f1e4c7f1"
}

variable "secgroup_id" {
  type    = string
  default = env("SECGROUP_ID")
}

source "huaweicloud-ecs" "sap_base_windows_image" {
  access_key         = "${var.access_key}"
  secret_key         = "${var.secret_key}"
  region             = "${var.region}"
  availability_zone  = "la-south-2a"
  flavor             = "s6.2xlarge.2"
  instance_name      = "packer-win-image-builder"
  image_name         = "sap_base_image_win_2019_${local.timestamp}"
  source_image       = "${var.source_image}"
  security_groups    = [var.secgroup_id]
  eip_bandwidth_size = 5 
  eip_type           = "5_bgp"
  communicator       = "winrm"
  winrm_username     = "administrator"
  winrm_insecure     = true
  winrm_use_ssl      = true
}

build {
  sources = [
    "source.huaweicloud-ecs.sap_base_windows_image",
  ]

  provisioner "file" {
    source      = "./Unattend.xml"
    destination = "C:\\Windows\\Temp\\Unattend.xml"
  }

  provisioner "powershell" {
    inline = [
      "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12",
      "$url = 'https://raw.githubusercontent.com/ansible/ansible-documentation/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'",
      "$file = \"$env:temp\\ConfigureRemotingForAnsible.ps1\"",
      "Write-Host \"Downloading script from $url to $file\"",
      "try {",
      "    (New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)",
      "    Write-Host 'Script downloaded successfully.'",
      "} catch {",
      "    Write-Host \"Error downloading script: $_\"",
      "    exit 1",
      "}",
      "Write-Host \"Executing PowerShell script: $file\"",
      "powershell.exe -ExecutionPolicy ByPass -File $file",
      "Write-Host 'Starting sysprep execution...'",
      "C:\\Windows\\System32\\sysprep\\sysprep.exe /generalize /oobe /unattend:C:\\Windows\\Temp\\Unattend.xml",
      "Write-Host 'Sysprep execution completed.'",
      # "Get-Content C:\\Windows\\System32\\Sysprep\\Panther\\setupact.log" # Uncomment this line to see the sysprep logs
    ]
  }
}
