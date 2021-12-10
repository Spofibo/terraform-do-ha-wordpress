# Highly available WordPress sites on DigitalOcean with Terraform and Ansible

This repository contains [Terraform](https://www.terraform.io/) and [Ansible](https://www.ansible.com/) configurations to launch and configure the infrastructure on DigitalOcean, and will create the following infrastructure using Terraform:

- One private VPC
- Two 1 GB Droplets in the FRA1 datacenter running Ubuntu 21.10
- One managed MySQL cluster with two DBs and two users
- One DigitalOcean Load Balancer to route HTTPS traffic to the Droplets
- One DigitalOcean Cloud Firewall to lock down communication between the Droplets and the outside world

We will then use Ansible to run the following tasks on both Droplets:

- Update all packages
- Install the DigitalOcean monitoring agent, to enable resource usage graphs in the Control Panel
- Install the Nginx web server software
- Install a demo `index.html` that shows Sammy and the Droplet's hostname


## Prerequisites

- **An SSH key set up on your local computer**, with the public key uploaded to the DigitalOcean Control Panel. You can find out how to do that using our tutorial [How To Use SSH Keys with DigitalOcean Droplets](https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets).
- **A personal access token for the DigitalOcean API**. You can find out more about the API and how to generate a token by reading [How To Use the DigitalOcean API v2](https://www.digitalocean.com/community/tutorials/how-to-use-the-digitalocean-api-v2)

When you have the software, an SSH key, and an API token, proceed to the first step.


## Step 1 — Clone the Repository and Configure

First, download the repository to your local computer using `git clone`, and enter the directory:

```shell
$ git clone https://github.com/Spofibo/terraform-do-ha-wordpress.git
$ cd terraform-do-ha-wordpress
```

We need to update a few variables to let Terraform know about our keys and tokens. Terraform will look for variables in any `.tfvars` file. An example file is included in the repo.

Then, copy the example file to to a new file, removing the `.example` extension:

```shell
$ cp terraform.tfvars.example terraform.tfvars
```

Open the new file in your favorite text editor, and update the content of the variables with your parameters:

```
do_token = ""
ssh_fingerprint = ""
```

Fill in each variable:

- **do_token:** is your personal access token for the DigitalOcean API
- **ssh_fingerprint:** the DigitalOcean API refers to SSH keys using their _fingerprint_, which is a shorthand identifier based on the key itself.

  To get the fingerprint for your key, run the following command, being sure to update the path (currently `~/.ssh/id_rsa.pub`) to the key you're using with DigitalOcean, if necessary:

  ```
  $ ssh-keygen -E md5 -lf ~/.ssh/id_rsa.pub | awk '{print $2}'
  ```

  The output will be similar to this:

  ```
  MD5:ac:eb:de:c1:95:18:6f:d5:58:55:05:9c:51:d0:e8:e3
  ```

  **Copy everything _except_ the initial `MD5:`** and paste it into the variable.

Now we can initialize Terraform. This will download some information for the DigitalOcean Terraform _provider_, and check our configuration for errors.

```
$ terraform init
```

You should get some output about initializing plugins. Now we're ready to provision the infrastructure and configure it.


## Step 2 — Run Terraform and Ansible

We can provision the infrastructure with the following command:

```
$ terraform apply
```

Terraform will figure out the current state of your infrastructure, and what changes it needs to make to satisfy the configuration in `terraform.tf`. In this case, it should show that it's creating two Droplets, a load balancer, a firewall, and a _null_resource_ (this is used to create the `inventory` file for Ansible).

If all looks well, type `yes` to proceed.

Terraform will give frequent status updates as it launches infrastructure. Eventually, it will complete and you'll be returned to your command line prompt. Take note of the IP that Terraform outputs at the end:

```
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

wordpress_lb_ip = 203.0.113.11
```

This is the IP of your new load balancer. If you navigate to it in your browser, you'll get an error: the Droplets aren't serving anything yet!

Let's fix that by running Ansible to finish setting up the servers:

```
$ cd ansible/
$ ansible-galaxy install -r requirements.yaml
$ ansible-playbook -i inventory playbook.yaml
```

Ansible will output some status information as it works through the tasks we've defined in `ansible.yml`. When it's done, the two Droplets will both be serving a unique web page that shows the hostname of the server.

Go back to your browser and enter the load balancer IP again. It may take a few moments to start working, as the load balancer needs to run some health checks before putting the Droplets back into its round-robin rotation. After a minute or so the demo web page with Sammy the shark will load:

![Demo web page with Sammy the shark and a hostname](https://assets.digitalocean.com/articles/tf-ansible-demo/demo-page.png)

If you refresh the page, you'll see the hostname toggle back and forth as the load balancer distributes the requests between both backend servers (some browsers cache more heavily than others, so you may have to hold `SHIFT` while refreshing to actually send a new request to the load balancer).

Take some time to browse around the DigitalOcean Control Panel to see what you've set up. Notice the two Droplets, `demo-01` and `demo-02` in your **Droplets** listing. Navigate to the **Networking** section and take a look at the `demo-lb` load balancer:

![DigitalOcean load balancer interface ](https://assets.digitalocean.com/articles/tf-ansible-demo/load-balancer.png)

In the **Firewalls** tab, you can investigate the `demo-firewall` entry. Notice how the Droplets are set up to only accept web traffic from the load balancer:

![DigitalOcean firewall rules interface](https://assets.digitalocean.com/articles/tf-ansible-demo/firewall.png)

When you're done exploring, you can destroy all of the demo infrastructure using Terraform:

```
$ terraform destroy
```

This will delete everything we've setup. Or, you could build upon this configuration to deploy your own web site or application! Read on for suggestions of further resources that might help.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | ~> 2.16 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | 2.16.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 2.1.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_database_cluster.mysql](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_cluster) | resource |
| [digitalocean_database_db.website1](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_db) | resource |
| [digitalocean_database_db.website2](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_db) | resource |
| [digitalocean_database_firewall.mysql](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_firewall) | resource |
| [digitalocean_database_user.website1](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_user) | resource |
| [digitalocean_database_user.website2](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_user) | resource |
| [digitalocean_droplet.wordpress](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet) | resource |
| [digitalocean_firewall.wordpress](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/firewall) | resource |
| [digitalocean_loadbalancer.wordpress](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/loadbalancer) | resource |
| [digitalocean_vpc.this](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/vpc) | resource |
| [local_file.ansible_inventory](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [http_http.myip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_do_token"></a> [do\_token](#input\_do\_token) | n/a | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | n/a | `string` | `"terraform2"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"fra1"` | no |
| <a name="input_ssh_fingerprint"></a> [ssh\_fingerprint](#input\_ssh\_fingerprint) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_wordpress_lb_ip"></a> [wordpress\_lb\_ip](#output\_wordpress\_lb\_ip) | n/a |
<!-- END_TF_DOCS -->