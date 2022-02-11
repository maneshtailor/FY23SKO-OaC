# Part 4: Creating New Relic Resources with Terraform
In this exercise we are going to create an alert and dashboard in New Relic via terraform and we'll test it works by sending some test data.

Pre-requsites:

1. A text editor such as VS Code
2. A test New Relic account that you can create User and Ingest API tokens for

## Step 1: Configure terraform 
You should already have the [providers.tf](./providers.tf) and [configuration.sh](./configuration.sh.example) file from previous exercises and terraform initialised. If not or you are starting from scratch follow the ["Configure Terraform" instructions](./Part_1-Spinning_up_an_AWS_EC2_instance.md) to get up and running.

## Step 2: Lights on the board
Our first step is to make sure that everything is configured correctly. We'll create an alert policy in the account and confirm it appears. 

Create a new file called `newrelic.tf`  and add the following code:
```newrelic.tf
resource "newrelic_alert_policy" "policy" {
  name = "YOURNAME alert policy"
  incident_preference = "PER_POLICY"
}
```

Run the terraform plan to see what changes are suggested. Remmeber to `source` the configuration file first if you havent already done so:

```
source configuration.sh
terraform plan
```

You should see something like this:

```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # newrelic_alert_policy.policy will be created
  + resource "newrelic_alert_policy" "policy" {
      + account_id          = (known after apply)
      + id                  = (known after apply)
      + incident_preference = "PER_POLICY"
      + name                = "jbuchanan terraform alert policy"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```

Now apply the configuration with:

```
terraform apply
```

This should apply the configuration and end with the message:
```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Check in your account for an alert policy called "YOURNAME terraform alert policy". If so then well done, youce vcreated your first New Relic resource via terraform.


## Step 3: Add an NRQL Condition to the policy
An alert policy with no conditions isnt very useful. We need to add an alert condition to the resource we created above. To do this we will use the documentation to find the resource we need and utilise the examples to configure it.

Start by finding the New Relic Terraform Provider documentation. Open up your favourtie search engine and search for "new relic terraform provider", with any luck the first result will take you to our [provider docs](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs).

In the "resources" section find the "newrelic_nrql_alert_condition" resource documentation. There are plenty of examples in the documentation that you can copy and paste and then amend. Notice in the first example there are two resources, the new_relic_alert_policy resource which we have already got in our project and the "newrelic_nrql_alert_condition" resource. Copy and paste *just* the large "newrelic_nrql_alert_condition" configuration block into `newrelic.tf` under the policy resource we added earlier:

```newrelic.tf
resource "newrelic_nrql_alert_condition" "foo" {
 ...
}
```

We need to tidy this up and configure it to our needs. Refer to the documentation to understand all the configuration options.
1. The resource  itself is called "foo" rename it to "demo"
2. `account_id`: Set this value to `var.NEW_RELIC_ACCOUNT_ID`
3. `policy_id': This controls which policy the condition is a member of, we need to supply the ID of the policy we created above. To do this set the value to `newrelic_alert_policy.policy.id` (our policy resource is named "policy" not "foo"!)
4. `name': Set this then name of the condition as it appears in New Relic. Set to something readable, e.g. "Demo alert condition". 
5. Delete the `description` and `runbook_url` attributes, we won't use them today.
6. `aggregation_method': Set this to `event_timer`
7. Add an attirbute `aggregation_timer` with a value of `60`
8. Delete `aggregation_delay` attribute
9. Delete `expiration_duration`, `open_violation_on_expiration` and `close_violations_on_expiration`. These settings control signal loss which we want to disable for this example.
10. `slide_by': Set this to zero.
11. `nrql > query`: This is an NRQL condition so we need to specify the NRQL here, set the value to: `select count(*) from tfdemo` (This "tfdemo" event type doesnt exist yet, we'll deal with that later.)
12. In the `critical` block set:
    - the `threshold` to `0` and 
    - the `threshold_duration` to `120`
    - the `threshold_occurrences` to `at_least_once`
13. Delete the entire `warning` block, we dont' care about warnings for this example.

Run `terraform apply` and you should see the condtion created:
```newrelic_nrql_alert_condition.demo: Creating...
newrelic_nrql_alert_condition.demo: Creation complete after 5s [id=1863121:23885590]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Check in the UI that the condition has indeed been created.

What did this all do? It created an NRQL alert condition that will fire if the count of records in tfdemo event is non-zero. Once you've applied the configuration take a look at the settings of the condition in the UI to understand it better.


## Step 4: Add a notification channel
When an alert fires it should notify someone. We're going to send your alert notifications to Slack. The first one there might win a prize! We will use the documentation to learn how to add a notification channel to the project.

Look for the "newrelic_alert_channel" resource in the documentaion and find the Slack example low down on the page. Copy the example into `newrelic.tf` beneath the condition resource we added previously.

```
resource "newrelic_alert_channel" "foo" {
 ...
}
```

As with the previous task we'll use this example code as a basis for our own and make changes accordingly. Update as follows:

1. Change the resource name from "foo" to "sko_slack" (note the underscore here!)
2. `name': Set this to the value "YOURNAME SKO Slack Channel" - this is the name that will appear in the New Relic UI
3. `config.url` Set this to: `HOOK VALUE SUPPLIED DURING SESSION`
4. `config.channel` Set this to `sko-oac`

Run `terraform apply` and observe the notification channel has been created in the UI.

## Step 5: Connect the notification channel
We have created an alert policy and a notification channel, but we havent connected them together. Multiple policies may leverage a single channel so this step is done seperately.

Find the "newrelic_alert_policy_channel" resource documentation. This is the resource that subscripes channels to policies. You can see here a full example. Copy and past just the last resource `newrelic_alert_policy_channel` in the top example into `newrelic.tf`:

```
resource "newrelic_alert_policy_channel" "foo" {
    ...
}
```

As before lets update the example to suit our needs:

1. Change the name of the resource from "foo" to "subscribe"
2. `policy_id': This is where we identify the policy we're adding the channel to, in this casew we need to reference the policy we created abiove. Set the value to: `newrelic_alert_policy.policy.id`
3. The `channel_ids` attribute is an array of channels. We only have one so set the value to reference our single channel like this: `[newrelic_alert_channel.sko_slack.id]`


Apply this change with `terraform apply` and confirm in the UI that your alert poilicy now has a notification channel attached.

** Side note **
Whilst we're here lets talk about resource referencing. In the step above we connected the alert policy resource we created initiall to the notification channel. When you refer to a resource in terraform you specify its attributes in the following format:

```
<resource_type>.<resource_name>.<attribute>
```

So in our case we neeed to supply the `id` of the resource type `newrelic_alert_policy` named `policy`:

```
newrelic_alert_policy.policy.id
```

## Step 6: Testing the alert
Everything is now setup and our alert policy and condition is diligently looking for problems. Lets send some data to trigger the alert and light up the slack channel.

Update this command with a API License key and your account ID, then run it a few times in your terminal to generate data. You should shortly see your alert policy trigger.

```
curl -X POST -H "Content-Type: application/json" \
-H "Api-Key: LICENSE-KEY-HERE" \
https://insights-collector.newrelic.com/v1/accounts/ACCOUNT-ID-HERE/events \
--data '[
  {
    "eventType":"tfdemo",
    "apples":1
  }
]'
```

(Note this is for the US data centre)
