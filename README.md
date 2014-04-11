# lita-digitalocean

[![Build Status](https://travis-ci.org/jimmycuadra/lita-digitalocean.png?branch=master)](https://travis-ci.org/jimmycuadra/lita-digitalocean)
[![Code Climate](https://codeclimate.com/github/jimmycuadra/lita-digitalocean.png)](https://codeclimate.com/github/jimmycuadra/lita-digitalocean)
[![Coverage Status](https://coveralls.io/repos/jimmycuadra/lita-digitalocean/badge.png)](https://coveralls.io/r/jimmycuadra/lita-digitalocean)

**lita-digitalocean** is a handler plugin for [Lita](https://www.lita.io/) that manages [DigitalOcean](https://www.digitalocean.com/) services.

## Installation

Add lita-digitalocean to your Lita instance's Gemfile:

``` ruby
gem "lita-digitalocean"
```

## Configuration

### Required attributes

* `client_id` (String) - The client ID for the account to manage.
* `api_key` (String) - The API key for the account to manage.

### Example

``` ruby
Lita.configure do |config|
  config.handlers.digitalocean.client_id = "BdCsMEJYPv2tu7xQtLRB3"
  config.handlers.digitalocean.api_key = "3df020a0441731e5ca47243b5515cbb7"
end
```

## Usage

TODO: Describe the plugin's features and how to use them.

## License

[MIT](http://opensource.org/licenses/MIT)
