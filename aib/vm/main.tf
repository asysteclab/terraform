variable "vsphere_username" {
  description = "vSphere Server admin username"
  default = "administrator@vsphere.local"
}

variable "vsphere_password" {
  description = "vSphere Server admin password"
  sensitive = true
}

variable "vsphere_server" {
  description = "vSphere Server to provision resources on"
  default = "alpiaasvclab.labvcf.aib.pri"
}

variable "vsphere_datacenter" {
  description = "vSphere datacenter to provision resources on"
  default = "VxRail-Datacenter"
}

variable "vsphere_datastore" {
  description = "vSphere datastore to provision resources on"
  default = "VxRail-Virtual-SAN-Datastore"
}

variable "vsphere_compute_cluster" {
  description = "vSphere cluster to provision resources on"
  default = "IaaSLab01"
}

variable "vsphere_network" {
  description = "vSphere network to provision resources on"
  default = "WIS_demo_segment"
}

provider "vsphere" {
  user                 = var.vsphere_username
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_compute_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = "terraform_test_vm"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = 1
  memory           = 1024
  guest_id         = "other3xLinux64Guest"

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size  = 20
  }
  wait_for_guest_net_timeout = 0
}

output "vsphere_virtual_machine" {
  value = vsphere_virtual_machine.vm.name
}
