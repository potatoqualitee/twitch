# tvbot


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

- Currently, the bot will most definintely timeout. I have to fix that.
- Tested reconnects
