# slack-mimic-yammer

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

## Overview

A gateway to Yammer acts as Slack incoming webhook.

## Usage

1. Set ```YAMMER_ACCESS_TOKEN``` ENV.
2. Run this app
3. Use ```http://your.host/services/{Yammer group_id}``` instead of Slack URL

### How to get Yammer group_id

1. Access to target Yammer Group.
2. Check the URL. Extract ```feedId=xxxxx```
3. xxxxx is your group_id.

### How to get Yammer access_token

Look https://github.com/yammer/yam#configuration

## Author

[mallowlabs](https://github.com/mallowlabs)

