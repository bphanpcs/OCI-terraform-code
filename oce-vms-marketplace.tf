# Configure the OCI provider
provider "oci" {
  tenancy_ocid = "YOUR_TENANCY_OCID"
  user_ocid = "YOUR_USER_OCID"
  fingerprint = "YOUR_FINGERPRINT"
  private_key_path = "YOUR_PRIVATE_KEY_PATH"
  region = "YOUR_REGION"
}

# Define variables for the VMs
variable "vm_count" {
  default = 2
}

variable "vm_name_prefix" {
  default = "my-vm"
}

variable "vm_shape" {
  default = "VM.Standard2.1"
}

variable "subnet_id" {
  default = "ocid1.subnet.oc1.iad.YOUR_SUBNET_OCID"
}

# Define the Ubuntu image from the OCI Marketplace
data "oci_marketplace_listings" "ubuntu_image" {
  compartment_id = "YOUR_COMPARTMENT_OCID"
  listing_id = "ocid1.appcataloglisting.oc1..YOUR_LISTING_OCID"
}

data "oci_marketplace_images" "ubuntu_image" {
  compartment_id = "YOUR_COMPARTMENT_OCID"
  listing_id = data.oci_marketplace_listings.ubuntu_image.listings.0.id
  version = "latest"
}

# Create the VM instances
resource "oci_core_instance" "vm" {
  count = var.vm_count

  display_name = "${var.vm_name_prefix}-${count.index+1}"
  compartment_id = "YOUR_COMPARTMENT_OCID"
  shape = var.vm_shape
  image_id = data.oci_marketplace_images.ubuntu_image.images.0.id
  subnet_id = var.subnet_id

  metadata = {
    ssh_authorized_keys = "YOUR_SSH_KEY"
  }

  # Allow unrestricted outbound Internet access
  network_security_group_ids = [oci_core_network_security_group.vm_nsg.id]
}

# Create a network security group to allow outbound Internet access
resource "oci_core_network_security_group" "vm_nsg" {
  compartment_id = "YOUR_COMPARTMENT_OCID"
  vcn_id = "YOUR_VCN_OCID"

  egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
  }
}
