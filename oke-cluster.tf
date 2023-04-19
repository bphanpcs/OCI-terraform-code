# Configure the OCI provider
provider "oci" {
  tenancy_ocid         = "YOUR_TENANCY_OCID"
  user_ocid            = "YOUR_USER_OCID"
  fingerprint          = "YOUR_API_KEY_FINGERPRINT"
  private_key_path     = "YOUR_API_PRIVATE_KEY_PATH"
  region               = "YOUR_REGION"
}

# Define the compartment ID
locals {
  compartment_id = "YOUR_COMPARTMENT_OCID"
}

# Create the OKE cluster
resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id = local.compartment_id
  name           = "my-oke-cluster"
  kubernetes_version = "v1.25.4"
  vcn_id         = "YOUR_VCN_OCID"
  kubernetes_network_config {
    pod_cidr_block = "10.244.0.0/16"
  }

  # Specify the number of worker nodes
  node_pools {
    subnet_id = "YOUR_SUBNET_OCID"
    node_shape = "VM.Standard2.1"
    initial_node_labels = {
      "nodepool" = "my-nodepool"
    }
    quantity_per_subnet = 1
  }
}

# Allow unrestricted Internet access from the OKE cluster
resource "oci_core_security_list" "oke_security_list" {
  compartment_id = local.compartment_id
  vcn_id         = "YOUR_VCN_OCID"
  egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
  }
  ingress_security_rules {
    protocol = "all"
    source = "0.0.0.0/0"
  }
}
