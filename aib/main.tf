terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
    }
  }
}

# NSX-T Manager Credentials
provider "nsxt" {
  host           = "10.59.64.128"
  username       = "admin"
  password       = "${var.nsxt_admin_pw}"
  global_manager = true
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]

}



# Create Service
resource "nsxt_policy_service" "SERPP-TEST" {
  description  = "L4 ports service provisioned by Terraform"
  display_name = "SERPP-TEST"

  l4_port_set_entry {
    display_name      = "TCP1"
    description       = "TCP port 80 entry"
    protocol          = "TCP"
    destination_ports = ["80"]
  }
  l4_port_set_entry {
    display_name      = "UDP1"
    description       = "UDP port 80 entry"
    protocol          = "UDP"
    destination_ports = ["80", "443"]
  }
}

# Create Group
resource "nsxt_policy_group" "SER-TEST" {
  display_name = "SER-TEST"
  description  = "Terraform provisioned Group"

  criteria {
    condition {
      key         = "Name"
      member_type = "VirtualMachine"
      operator    = "STARTSWITH"
      value       = "public"
    }
    condition {
      key         = "OSName"
      member_type = "VirtualMachine"
      operator    = "EQUALS"
      value       = "Ubuntu"
    }
  }

  conjunction {
    operator = "OR"
  }

  criteria {
    ipaddress_expression {
      ip_addresses = ["211.1.1.1", "192.168.1.1-192.168.1.100"]
    }
  }
}

# DFW Application Category Rules
resource "nsxt_policy_security_policy" "USR-TEST" {
  display_name = "USR-TEST"
  description  = "Terraform provisioned Security Policy"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = false
  scope        = [nsxt_policy_group.SER-TEST.path]


  rule {
    display_name       = "block_icmp"
    destination_groups = [nsxt_policy_group.SER-TEST.path]
    action             = "DROP"
    services           = [nsxt_policy_service.SERPP-TEST.path]
    logged             = true
  }
}
