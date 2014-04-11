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

To use any of the DigitalOcean commands, the user sending the message must be in the `:digitalocean_admins` authorization group.

### Domain commands

Not yet implemented. Coming soon!

### Droplet commands

Not yet implemented. Coming soon!

### Image commands

Not yet implemented. Coming soon!

### Region commands

Not yet implemented. Coming soon!

### SSH key commands

To add a new SSH key and get back its ID:

```
Lita: do ssh keys add NAME PUBLIC_KEY
```

To delete an SSH key by its ID:

```
Lita: do ssh keys delete ID
```

To edit the name and/or public key of an existing SSH key:

```
Lita: do ssh keys edit ID [name=NAME] [public_key=PUBLIC_KEY]
```

To list the names and IDs of all SSH keys:

```
Lita: do ssh keys list
```

To show the name and public key of an SSH key by ID:

```
Lita: do ssh keys show ID
```

### Size commands

Not yet implemented. Coming soon!

## License

[MIT](http://opensource.org/licenses/MIT)
