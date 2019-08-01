# Applying updates

```sh
terraform plan -out plan
```

Review the plan and make sure it's what you're changing.

Then, apply the plan:

```sh
terraform apply plan
```

# Environment variables

```sh
export ARM_ACCESS_KEY=<secret>
```
