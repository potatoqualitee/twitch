
## tvbot

<img align="left" src="https://github.com/potatoqualitee/twitch/blob/main/tvbot/icon.png?raw=true" alt="tvbot logo">  <br/></br>`tvbot` is a PowerShell bot for [https://twitch.tv](twitch.tv) that works on Windows, Linux, mac OS and Raspberry Pi. This bot can be used strictly to respond to channel events and/or you can use it to visually display events that are occuring. If you do want to use it as a notify bot, installing [BurntToast](https://github.com/Windos/BurntToast) gives the best experience in Windows 10.

## Install

Create a bot account on twitch, then get an oauth token from [twitchtokengenerator.com](https://twitchtokengenerator.com/) or [twitchapps.com/tmi](https://twitchapps.com/tmi/).


Next, change your execution policy, if needed, then install `tvbot` from the PowerShell Gallery.

```
# Set execution policy to allow local scripts
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# OPTIONAL: Trust the Microsoft Gallery to avoid prompts
Set-PSRepository PSGallery -InstallationPolicy Trusted

# Install the tvbot PowerShell module
Install-Module tvbot
```

## Config

Once `tvbot` is installed, set your bot client id and token using the token generated earlier.

```
$splat = @{
    BotClientId = "abcdefh01234567ijklmop"
    BotToken    = "01234567fghijklmnopqrs"
    BotChannel  = "potatoqualitee"
    BotOwner    = "potatoqualitee", "afriend"
    NotifyType  = "chat"
}

Set-TvConfig @splat
```

If you do not set a channel, the bot will join its own channel.

## Start

Next, start it up.

```
Start-TvBot
```

If you are on a Windows 10 machine and running PowerShell 5.1, the bot will open a new window, then minimize to the taskbar as a notify icon.

![image](https://user-images.githubusercontent.com/8278033/104730790-f714fe80-573a-11eb-8faf-7c36dad51e3f.png)

You'll also be notified of chats, follows, subs and more.

![image](https://user-images.githubusercontent.com/8278033/104730455-5f171500-573a-11eb-8519-b6b4710833f3.png)

Note that Windows Terminal does not support minimizing the bot to the taskbar. You'll have to use `powershell.exe`, unless you specify `-NoHide`. To run the bot in the current console, use the `-NoHide` parameter. This will disable

```
Start-TvBot -NoHide
```

If you are running the bot in Linux or the Windows Terminal, `-NoHide` will be automatically added for you.

![image](https://user-images.githubusercontent.com/8278033/104730206-e912ae00-5739-11eb-97dd-d9c0b8bd9f26.png)

Note that this will run the bot infinitely so you will not be brought back to a prompt.

To run the bot as a background job, run the following:
```
Start-Job -ScriptBlock { Start-TvBot -NoHide }
```

Or, if you're on Linux or Mac, just run

```
Start-TvBot &
```

## Interact
In your chat room, users execute the following commands:

* `!ping` - says "pong" back
* `!pwd` - shows the present working directory
* `!psversion` - displays the powershell version
* `!hello` - says "hi!" back
* `!say` - says whatever

The owner(s) of the bot can issue the following command:

* `!quit` - disconnects the bot and quits the script

To interact with the bot, join the same channel and execute a command.