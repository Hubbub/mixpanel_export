# Mixpanel Exporter

Uses the Mixpanel API to dump an event stream to CSV.

## Usage

```
export API_KEY="my_api_key"
export API_SECRET="my_api_secret"
bundle install

ruby export.rb 2015-01-01 2015-01-30 "Added Item to Basket"
```

The event name is optional, if not provided all events will be exported.

You can get your API key and secret in the Mixpanel web UI by going selecting
the projects tab within account management. Each project has its own API key.
