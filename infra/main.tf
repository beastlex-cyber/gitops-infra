terraform {
  required_providers {
    decort = {
      source  = "basis/decort/decort"
      version = "4.11.3"
    }
  }
}


provider "decort" {
  authenticator        = "decs3o"
  controller_url       = "https://crps1.crps.basis.loc"
  oauth2_url           = "https://sso-crps1.crps.basis.loc"
  allow_unverified_ssl = true
}


resource "decort_kvmvm" "base-kvm" {
  name = "base-kvm"
  rg_id = 14
  cpu = 4
  ram = 8192
  storage_policy_id = 13
  boot_disk_size = 100
  image_id = 10
}
