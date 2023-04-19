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
  display_name   = "example-vcn"
}

# Create a subnet within the VCN in the specified compartment and availability domain
resource "oci_core_subnet" "this" {
  cidr_block     = "<SUBNET_CIDR_BLOCK>"
  compartment_id = local.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "example-subnet"
  dns_label      = "examplesub"
  availability_domain = "<AVAILABILITY_DOMAIN>"
}

# Create the first VM instance within the subnet in the specified compartment and availability domain
resource "oci_core_instance" "vm1" {
  compartment_id = local.compartment_ocid
  availability_domain = "<AVAILABILITY_DOMAIN>"
  shape = "VM.Standard.E3.Flex"

  display_name = "vm1"

  # Use an existing image as the source for the instance
  source_details {
    source_type = "image"
    source_id = "ocid1.image.oc1..<your_image_id>"
  }

  # Create a VNIC for the instance and attach it to the subnet
  create_vnic_details {
    subnet_id = oci_core_subnet.this.id
    display_name = "vm1-vnic"
    hostname_label = "vm1"
  }
}

# Create the second VM instance within the subnet in the specified compartment and availability domain
resource "oci_core_instance" "vm2" {
  compartment_id = local.compartment_ocid
  availability_domain = "<AVAILABILITY_DOMAIN>"
  shape = "VM.Standard.E3.Flex"

  display_name = "vm2"

  # Use an existing image as the source for the instance
  source_details {
    source_type = "image"
    source_id = "ocid1.image.oc1..<your_image_id>"
  }

  # Create a VNIC for the instance and attach it to the subnet
  create_vnic_details {
    subnet_id = oci_core_subnet.this.id
    display_name = "vm2-vnic"
    hostname_label = "vm2"
  }
}
