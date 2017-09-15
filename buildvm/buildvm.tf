provider "vsphere" {
  user           = "ccooney"
  vsphere_server = "vc-01.lab.adms.local"

  # if you have a self-signed cert testchange
  allow_unverified_ssl = true
}

resource "vsphere_folder" "TF" {
  path = "IT-Staff/CCC/TF"
  datacenter = "ADMS-LL-DC"
}

resource "vsphere_virtual_machine" "web01" {
  name   = "web01"
  vcpu   = 2
  memory = 1024
  datacenter = "ADMS-LL-DC"
  folder = "${vsphere_folder.TF.path}"
  resource_pool = "ATLL-DellR730xd/ATLL-CLU/Resources/Terraform"

  network_interface {
     label = "ATLL-PhyNet/vxw-dvs-55-virtualwire-42-sid-5013-NST-GuestVM-CCC-LS"
     ipv4_address       = "10.27.0.39"
     ipv4_prefix_length = "24"
     ipv4_gateway       = "10.27.0.1"
  }

  disk {
    template = "Templates/Ubuntu1604-Base-Image"
    datastore = "ATLL-VSAN-DS"
  }
}
