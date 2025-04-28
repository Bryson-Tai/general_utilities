# Ways of Reference to resources

## Taskfile

Refer to example below

```yaml
version: "3"

includes:
  # <git_repo_url>//<path_to_taskfile>?ref=<branch_name>
  general_utilities: https://github.com/Bryson-Tai/general_utilities.git//Taskfile/minikube.yaml?ref=main

tasks:
  test:remote:
    desc: Test for remote task
    deps:
      # refer to includes key:task_name
      - general_utilities:.pre:minikube:start
    cmds:
      - echo "Hello"
```
