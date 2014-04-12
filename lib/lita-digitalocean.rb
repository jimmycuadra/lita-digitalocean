# This unfortunate monkey patch can be removed when a new i18n gem is released with the
# following patch in it: https://github.com/svenfuchs/i18n/pull/250
class Hash
  def slice(*keep_keys)
    h = self.class.new
    keep_keys.each { |key| h[key] = fetch(key) }
    h
  end
end

require "lita"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require "lita/handlers/digitalocean"
