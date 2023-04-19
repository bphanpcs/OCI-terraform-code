# Configure the required providers and their versions
terraform {
  required_providers {
    oci = {
      source  = "oracle-terraform-modules/oci"
      version = ">= 4.40.0"
    }
  }
}

# Configure the OCI provider with your authentication details
provider "oci" {
  tenancy_ocid     = "<TENANCY_OCID>"
  user_ocid        = "<USER_OCID>"
  fingerprint      = "<FINGERPRINT>"
  private_key_path = "<PRIVATE_KEY_PATH>"
  region           = "<REGION>"
}

# Define the compartment OCID in a local variable for reuse
locals {
  compartment_ocid = "<COMPARTMENT_OCID>"
}

# Create a Virtual Cloud Network (VCN) in the specified compartment
resource "oci_core_vcn" "this" {
  cidr_block     = "<VCN_CIDR_BLOCK>"
  compartment_id = local.compartment_ocid
  display_name   = "oke-vcn"
}

# Create the first regional subnet within the VCN for the Kubernetes worker nodes
resource "oci_core_subnet" "subnet1" {
  cidr_block     = "<SUBNET1_CIDR_BLOCK>"
  compartment_id = local.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "oke-subnet1"
  dns_label      = "okesub1"
  prohibit_public_ip_on_vnic = true
}

# Create the second regional subnet within the VCN for the Kubernetes worker nodes
resource "oci_core_subnet" "subnet2" {
  cidr_block     = "<SUBNET2_CIDR_BLOCK>"
  compartment_id = local.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "oke-subnet2"
  dns_label      = "okesub2"
  prohibit_public_ip_on_vnic = true
}

# Create a security list for the VCN to allow required traffic for Kubernetes cluster
resource "oci_core_security_list" "oke_security_list" {
  compartment_id = local.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "oke-security-list"

  # Allow traffic between Kubernetes worker nodes and control plane
  ingress_security_rules {
    source       = oci_core_vcn.this.cidr_block
    protocol     = "all"
  }
  egress_security_rules {
    destination  = oci_core_vcn.this.cidr_block
    protocol     = "all"
  }
}

# Create an OKE cluster in the specified compartment
resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id = local.compartment_ocid
  name           = "example-oke-cluster"
  kubernetes_version = "v1.25.4" # Use the desired Kubernetes version
  vcn_id         = oci_core_vcn.this.id

  # Configure the default node pool with 2 nodes
  default_node_pool {
    name                 = "default-node-pool"
    subnet_ids           = [oci_core_subnet.subnet1.id, oci_core_subnet.subnet2.id]
    node_shape           = "VM.Standard.E3.Flex"
    quantity_per_subnet  = 1 # Set to 1 to create 2 nodes across 2 subnets
  }
}
