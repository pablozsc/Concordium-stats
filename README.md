# Concordium-stats
Description of creating a telegram bot for monitoring a node in the Concordium network. 

## Step 1: bot TOKEN

We create our own new bot, so we go to the [@Botfather](https://t.me/BotFather). Botfather is the one bot to rule them all. Use it to create new bot accounts and manage your existing bots. 

- launch it and give it the `/newbot` command
- When asked for a name for your new bot choose something that ends with the word bot, so for example YOUR_NODE_NAMEbot
- If your chosen name is available, BotFather will then send you a TOKEN
- Save this TOKEN as you will be asked for it once you execute the installstats.sh script

Once your bot created, you can customize it with your own style, if you want. Do not forget to activate it in your telegram - just find it and press start
Let's go further

## Step 2: Obtain Your Chat Identification Number

Visit my dedicated telegram bot here [@CCDStatsChatID_bot](https://t.me/CCDStatsChatID_bot) for collecting your Chat ID that you will be asked for when you run installstats.sh in Step 3 that follows. Just send any message to the bot - your Chat_id will be sent back. Note that there may be a delay in responding with your chat_id. But usually everything is fast. You can delete this bot after obtaining your chat_id

## Step 3: Download & Setup The Scripts Required For Concordium Stats

```
cd ~
mkdir concordium-stats
cd concordium-stats
wget -O installstats.sh https://raw.githubusercontent.com/pablozsc/Concordium-stats/master/installstats.sh
sudo chmod +x installstats.sh && ./installstats.sh
```

You will be asked a series of questions regarding the metrics. Each answer will have a suggested answer. Please type in your own answer to each question pressing enter after each one. Once thats finished lets download the main stats.sh script below.

```
wget -O stats.sh https://raw.githubusercontent.com/pablozsc/Concordium-stats/master/stats.sh
sudo chmod +x stats.sh && chown $USER:$USER stats.sh
```

## Step 4: Test your Telegram bot

Test that your telegram bot is setup correctly by running the following

```
wget -O telegramtest.sh https://raw.githubusercontent.com/pablozsc/Concordium-stats/master/telegramtest.sh
sudo chmod +x telegramtest.sh && ./telegramtest.sh

```

## Step 5: Alerts test

You can manually edit the config.ini file and set the required metrics in order to test the alerts. To do this, enter:

```
sudo nano ~/concordium-stats/config.ini
```
Once you have made the changes press Ctrl + X and then press Y to save.


Now just wait for 1 minute cycle, or you can manually run the script stats.sh to bypass the schedule.
```
~/concordium-stats/stats.sh
```
