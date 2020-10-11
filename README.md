
## Getting Started

<img align="left" src=https://user-images.githubusercontent.com/8278033/95674723-6c0fef80-0bb2-11eb-8156-fbb026255c94.png alt="dbatools logo">  <br/></br>`tvbot` is a proof of concept PowerShell bot for [https://twitch.tv](twitch.tv) that works on the Raspberry Pi. It supports user commands and admin commands which can be imported from JSON files.
<br/></br>
## Getting Started

Once this is published to the PowerShell Gallery, you will just need to run the following code to start testing your bot:
```
Set-ExecutionPolicy Bypass -Scope CurrentUser
Install-Module tvbot
Start-TvBot -Name mypsbot -Owner potatoqualitee -Token 01234567890abcdefghijklmnopqrs -Channel potatoqualitee
```

This starts a bot named mypsbot (which, in this case, would be a twitch account), then joins the `potatoqualitee` chat room. It responds to 3 commands in total

* `!ping` - says "pong" back
* `!pwd` - shows the present working directory

The owner(s) of the bot can issue the following command:

* `!quit` - disconnects the bot and quits the script


## TODO

- Automatic reconnects
