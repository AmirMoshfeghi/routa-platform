# Versions verified 2026-08-17 against:
#   https://github.com/verda-cloud/terraform-provider-verda/releases   (verda v1.1.2)
#   https://github.com/hashicorp/terraform-provider-local/releases    (local v2.9.0)
# Re-check the registry before bumping — the verda provider is young and pre-1.0
# semantics lingered past the v1.0.0 tag in places. Do not widen these casually.

terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    verda = {
      source  = "verda-cloud/verda"
      version = "1.1.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.9.0"
    }
  }
}
