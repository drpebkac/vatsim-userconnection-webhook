param(
  [string]$VatsimSID,
  [string]$WebhookURL,
  [string]$hookusername = "Vatsim connection notifier"
)

function RunWebhook
{
  $UTCTime = ([System.DateTime]::UtcNow).ToString("HHmm")
  $Subject = "@everyone ATTN CONTROLLERS! $VatsimSID has connected to VATSIM AT $($UTCTime)z"
  
  if($CallSignOnConnection -eq $CallSignOnFPN)
  {
    $Content = [PSCustomObject]@{
      username = $hookusername
      content = $Subject
      embeds = @(
        @{
           title = 'Flight Information'
           fields = @(
            @{
                name = "Callsign"
                value = $CallSignOnConnection
            },
            @{
                name = "Aircraft"
                value = $Aircraft
            },
            @{
                name = "Departure"
                value = $DepartureAirport
            },
            @{
                name = "Arrival"
                value = $ArrivalAirport
            },
            @{
                name = "Cruise Alt"
                value = $CruisingFL
            },
            @{
                name = "RMKS"
                value = $Rmks
            },
            @{
                name = "Route"
                value = $Route
            }
          )
        }
      )
    }
  }
  else
  {
    $Content = [PSCustomObject]@{
      username = $hookusername
      content = $Subject
      embeds = @(
        @{
           title = 'Flight Information'
           fields = @(
            @{
                name = "No flight plan has been pre-filed by this user."
                value = "VATSIM API does not provide details of departing airport based on where user connects to on vpilot/xpilot"
             },
            @{
                name = "Callsign"
                value = $CallSignOnConnection
             }
           )
        }
      )
    }
  }

  $Json = ConvertTo-Json -depth 100 -InputObject $Content
  Invoke-WebRequest -uri $WebhookURL -Method POST -Body $JSON -Content 'application/json'

}

function FetchData
{
  while($true)
  {
    $ConnectionResults = Invoke-WebRequest `
    -ContentType "application/json" `
    -Uri "https://api.vatsim.net/api/ratings/$VatsimSID/connections" `
    -Method GET

    $OnlineStatus = ((ConvertFrom-Json -InputObject $ConnectionResults).Results | Select -First 1).end
    $CallSignOnConnection = ((ConvertFrom-Json -InputObject $ConnectionResults).Results | Select -First 1).callsign

    $FlightPlanResults = Invoke-WebRequest `
    -ContentType "application/json" `
    -Uri "https://api.vatsim.net/api/ratings/$VatsimSID/flight_plans" `
    -Method GET
    
    $CallSignOnFPN = ((ConvertFrom-Json -InputObject $FlightPlanResults).Results | Select -First 1).callsign
    $Aircraft = ((ConvertFrom-Json -InputObject $FlightPlanResults).Results | Select -First 1).aircraft
    $DepartureAirport = ((ConvertFrom-Json -InputObject $FlightPlanResults).Results | Select -First 1).dep
    $ArrivalAirport = ((ConvertFrom-Json -InputObject $FlightPlanResults).Results | Select -First 1).arr
    $CruisingFL = ((ConvertFrom-Json -InputObject $FlightPlanResults).Results | Select -First 1).altitude
    $Rmks = ((ConvertFrom-Json -InputObject $FlightPlanResults).Results | Select -First 1).rmks
    $Route = ((ConvertFrom-Json -InputObject $FlightPlanResults).Results | Select -First 1).Route

    if(!$OnlineStatus)
    {
      if(!$FunctionStatus -or $FunctionStatus -eq "Offline")
      {
        Write-Output "Player $VatsimSID is online"
        RunWebhook
        $FunctionStatus = "Online"
      }
      else
      {
        Write-Output "User is still connected"
      }
    }
    else
    {
      Write-Output "Player $VatsimSID is offline"
      $FunctionStatus = "Offline"
    }

    sleep 10
  }
}

do
{
  while(!$VatsimSID)
  {
    $VatsimSID = Read-Host "Please enter the Vatsim SID for the Bot to track"
  }
  while(!$WebhookURL)
  {
    $WebhookURL = Read-Host "Please enter the Discord webhook URL for the bot to use"
  }

} until ($VatsimSID -and $WebhookURL)

FetchData
