# vatsim-userconnection-webhook
A Discord script that acts like a minibot to provide Discord notifications when a particular Vatsim user connects to the network via v/xpilot.

# Disclaimer - This is the older script. For the newer one, use the Serverless deployment stack template for Azure Function

![image](https://user-images.githubusercontent.com/67497646/182026836-846b1555-729d-4b95-aa9f-19be65d63a74.png)

## How it works

The Powershell script runs as a daemon and performs HTTP GET requests against the Vatsim API every 10 seconds. Based on a VATSIM SID that is passed through as params, it will obtain the Vatsim user's connection details and pre-flight plan details. These details are then composed into json and POSTed to Discord webhooks. 

A user who is online is determined by the `end` property on https://api.vatsim.net/api/ratings/{idnum}/connections/
- If the value is null, it means the user is connected. A webhook will be sent to Discord
- If the value has a date, it means the user has disconnected. No webhooks will be sent to Discord

## How to use
1. Enable ExecutionPolicy on Powershell. A guide on how to do this can be found here. https://windowstect.com/set-powershell-execution-policy-as-unrestricted/
2. Create a webhook URL on your particular channel on your server for the webhooks to be dumped to.
3. Make sure you have obtained the SID for a specific VATSIM user.
4. Open Powershell, Navigate to the Script.
5. Run the script and pass the following params.

| Param        | Description                                                                 | Required |
|--------------|-----------------------------------------------------------------------------|----------|
| VatsimID     | The 6-7 digit number that represents the user on Vatsim                     | Yes      |
| WebhookURL   | The url that represents the Discord channel for the webhook to dump info on | Yes      |
| hookusername | The name of the webhook. (Default value is Vatsim connection notifier)      | No       |

#### Example

`run.ps1 -$VatsimSID 0000000 -WebhookURL "https://discord.com/api/webhooks/000000000000000000000/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"`

## Uptime

Not garenteed.
