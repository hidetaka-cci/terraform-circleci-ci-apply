locals {
  projects = toset([
    "terraform-circleci-ci-apply",
  ])
}

resource "circleci_project" "this" {
  for_each = local.projects

  name              = each.key
  organization_id   = var.organization_id
  set_github_status = false
  auto_cancel_builds  = true
}

resource "circleci_pipeline" "build" {
  project_id  = circleci_project.this["terraform-circleci-ci-apply"].id
  name        = "build"
  description = "GitHub App pipeline for terraform CI apply verification"

  config_source_provider         = "github_app"
  config_source_repo_external_id = var.repo_external_id
  config_source_file_path        = ".circleci/config.yml"

  checkout_source_provider         = "github_app"
  checkout_source_repo_external_id = var.repo_external_id
}

resource "circleci_trigger" "all_pushes" {
  project_id  = circleci_project.this["terraform-circleci-ci-apply"].id
  pipeline_id = circleci_pipeline.build.id

  event_source_provider         = "github_app"
  event_source_repo_external_id = var.repo_external_id
  event_preset                  = "all-pushes"

  lifecycle {
    ignore_changes = [pipeline_id]
  }
}
