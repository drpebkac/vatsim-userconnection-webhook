# vatsim-userconnection-webhook
A Discord minibot that runs a webhook each time a particular user (SID) connects to the network. The purpose is to receive notifications of a particular Vatsim user whenever they connect to v/xpilot.

## How it works

The Powershell script runs as a daemon and HTTP GET requests the Vatsim API every 10 seconds, based on a VATSIM SID its given. By doing this, it will obtain the Vatsim user's connection details and pre-flight plan details. These details are then composed into json and POSTed to Discord webhooks. 


## How to use
1. First create a webhook URL on a particular channel for your server for the webhooks to be dumped on
2. Make sure you have obtained the SID for a specific VATSIM user
3. Run the script and pass the following params

| Param        | Description                                                                 | Required |
|--------------|-----------------------------------------------------------------------------|----------|
| VatsimID     | The 6-7 digit number that represents the user on Vatsim                     | Yes      |
| WebhookURL   | The url that represents the Discord channel for the webhook to dump info on | Yes      |
| hookusername | The name of the webhook. (Default value is Vatsim connection notifier)      | No       |

#### Example

`run.ps1 -$VatsimSID 0000000 -WebhookURL "https://discord.com/api/webhooks/000000000000000000000/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"`
