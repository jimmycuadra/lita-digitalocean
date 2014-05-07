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

To create a new DNS record set:

```
Lita: do domains create NAME IP
```

To delete a DNS record set:

```
Lita: do domains delete DOMAIN_NAME_OR_ID
```

To list all DNS record sets:

```
Lita: do domains list
```

To show the details of a DNS record set:

```
Lita: do domains show DOMAIN_NAME_OR_ID
```

### Domain record commands

To create a new DNS record:

```
Lita: do domain records create DOMAIN_NAME_OR_ID TYPE DATA [name=NAME] [priority=PRIORITY] [port=PORT] [weight=WEIGHT]
```

To delete a DNS record:

```
Lita: do domain records delete DOMAIN_NAME_OR_ID DOMAIN_RECORD_ID
```

To edit a DNS record:

```
Lita: do domain records edit DOMAIN_NAME_OR_ID DOMAIN_RECORD_ID TYPE DATA [name=NAME] [priority=PRIORITY] [port=PORT] [weight=WEIGHT]
```

To list all DNS records for a DNS record set:

```
Lita: do domain records list DOMAIN_NAME_OR_ID
```

To show the details of a DNS record:

```
Lita: do domain records show DOMAIN_NAME_OR_ID DOMAIN_RECORD_ID
```

### Droplet commands

To create a droplet:

```
Lita: do droplets create HOSTNAME SIZE_ID_OR_SLUG IMAGE_ID_OR_SLUG REGION_ID_OR_SLUG [ssh_key_ids=SSH_KEY_IDS] [private_networking=true|false] [backups_enabled=true|false]
```

To delete a droplet, optionally writing zeroes to the disk first:

```
Lita: do droplets delete ID [--scrub]
```

To list all droplets:

```
Lita: do droplets list
```

To reset the root password for a droplet:

```
Lita: do droplets password reset ID
```

To power cycle a droplet:

```
Lita: do droplets power cycle ID
```

To power off a droplet:

```
Lita: do droplets power off ID
```

To power on a droplet:

```
Lita: do droplets power on ID
```

To reboot a droplet:

```
Lita: do droplets reboot ID
```

To rebuild a droplet:

```
Lita: do droplets rebuild ID IMAGE_ID
```

To resize a droplet's disk:

```
Lita: do droplets resize ID SIZE_ID_OR_SLUG
```

To restore a droplet from an image:

```
Lita: do droplets restore ID IMAGE_ID
```

To show the details of a droplet:

```
Lita: do droplets show ID
```

To shut down a droplet:

```
Lita: do droplets shutdown ID
```

To take a snapshot of a droplet, optionally naming the snapshot:

```
Lita: do droplets snapshot ID [NAME]
```

### Image commands

To delete an image:

```
Lita: do images delete ID_OR_SLUG
```

To list all possible images:

```
Lita: do images list
```

To list only global images:

```
Lita: do images list global
```

To list only your own images:

```
Lita: do images list my_images
```

To show the details of an image:

```
Lita: do images show ID_OR_SLUG
```

### Region commands

To list all the possible regions:

```
Lita: do regions list
```

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

To list all the possible image sizes:

```
Lita: do sizes list
```

## License

[MIT](http://opensource.org/licenses/MIT)
