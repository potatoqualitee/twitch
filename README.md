
## Getting Started

<img align="left" src=https://user-images.githubusercontent.com/8278033/95674723-6c0fef80-0bb2-11eb-8156-fbb026255c94.png alt="dbatools logo">  <br/></br>`tvbot` is a proof of concept PowerShell bot for [https://twitch.tv](twitch.tv) that works on the Raspberry Pi. It supports user commands and admin commands which can be imported from JSON files.
<br/></br>
## Install

Create a bot account on twitch, then get an oauth token from [twitchapps.com/tmi](https://twitchapps.com/tmi/).

Next, change your execution policy then install `tvbot` from the PowerShell Gallery.

```
# Set execution policy to allow local scripts
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# OPTIONAL: Trust the Microsoft Gallery to avoid prompts
Set-PSRepository PSGallery -InstallationPolicy Trusted

# Install the tvbot PowerShell module
Install-Module tvbot
```

## Run
Once `tvbot` is installed, start it up. Note that this will run the bot infinitely so you will not be brought back to a prompt.
```
# Start your bot
Start-TvBot -Name mypsbot -Owner potatoqualitee -Token 01234567890abcdefghijklmnopqrs -Channel potatoqualitee
```

To run the bot as a background job, run the following:
```
Start-Job -ScriptBlock { Start-TvBot -Name mypsbot -Owner potatoqualitee -Token 01234567fghijklmnopqrs -Channel potatoqualitee }
```

## Interact
This starts a bot named mypsbot (which, in this case, would be a twitch account), then joins the `potatoqualitee` chat room. It responds to 3 commands in total

* `!ping` - says "pong" back
* `!pwd` - shows the present working directory

The owner(s) of the bot can issue the following command:

* `!quit` - disconnects the bot and quits the script

To interact with the bot, join the same channel and execute a command.

## TODO

- Automatic reconnects
