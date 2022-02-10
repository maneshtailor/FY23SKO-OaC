# FY23SKO-OaC

## Requirements

* [Homebrew](https://brew.sh/)
* [Visual Studio Code](https://code.visualstudio.com/) or another code editor
* Terraform / Ansible / New Relic CLI / Git: `brew install terraform ansible newrelic-cli git`

You can check if everything is installed correctly by running the following commands:

```

terraform -v
ansible --version
newrelic -v
git --version
```

You should get output similar to this:
```
terraform -v
ansible --version
newrelic -v
git --version
Terraform v1.1.4
on darwin_amd64
+ provider registry.terraform.io/hashicorp/aws v3.74.0
+ provider registry.terraform.io/newrelic/newrelic v2.35.1

Your version of Terraform is out of date! The latest version
is 1.1.5. You can update by downloading from https://www.terraform.io/downloads.html
ansible [core 2.12.1]
  config file = None
  configured module search path = ['/Users/samuel/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/Cellar/ansible/5.2.0/libexec/lib/python3.10/site-packages/ansible
  ansible collection location = /Users/samuel/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible
  python version = 3.10.1 (main, Dec  6 2021, 22:25:40) [Clang 13.0.0 (clang-1300.0.29.3)]
  jinja version = 3.0.3
  libyaml = True
newrelic version 0.41.17
git version 2.34.1
```

## Guides

* Part 1: [Spinning up an AWS EC2 instance with Terraform](./Part_1-Spinning_up_an_AWS_EC2_instance.md)
* Part 2: [Enabling New Relic Cloud Integrations](./Part_2-Enabling_cloud_integrations.md)
* Part 3: [Deploying New Relic with Ansible](./Part_3-Deploying_New_Relic.md)
* Part 4: [Creating Synthetic scripts, alerts and dashboards with Terraform](./Part_4-Creating_synchetic_scripts_and_dashboards.md)
* Part 5: [Bonus Round! Common CLI use-cases](./Part_5-Bonus_round_CLI.md)
