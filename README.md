# Ways of Reference to resources

## Taskfile

Refer to example below

```yaml
version: "3"

includes:
  # <git_repo_url>//<path_to_taskfile>?ref=<branch_name>
  gen_utils_minikube: https://github.com/Bryson-Tai/general_utilities.git//Taskfiles/minikube.yaml?ref=main

tasks:
  test:remote:
    desc: Test for remote task
    deps:
      # refer to includes key:task_name
      - gen_utils_minikube:.pre:minikube:start
    cmds:
      - echo "Hello"
```

## OpenTofu

Refer to example below to use the modules in OpenTofu:

```hcl
  module "aks" {
    source = "git::https://github.com/Bryson-Tai/general_utilities.git//opentofu/azure/<module_dir_name>?ref=main"
  }
```
