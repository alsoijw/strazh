require "twostroke"
require "./helpers"
require "./*"

# TODO: Write documentation for `Strazh`
module Strazh
  extend self
  VERSION = "0.1.0"

  def pretty(obj)
    red = `tput setaf 1`
    green = `tput setaf 2`
    yellow = `tput setaf 3`
    pink = `tput setaf 5`
    blue = `tput setaf 6`
    reset = `tput sgr0`

    obj.pretty_inspect
      .gsub(/<([A-Z][a-zA-Z]*(::[A-Za-z][A-Za-z]*)*)/) { |_| "<#{red}#{$1}#{reset}" }
      .gsub(/([^:])(:[a-z]+)/i) { |_| "#{$1}#{pink}#{$2}#{reset}" }
      .gsub(/"([^"]+)"/) { |_| "#{green}\"#{$1}\"#{reset}" }
      .gsub(/=([\d\.\d]+)/) { |_| "=#{yellow}#{$1}#{reset}" }
      .gsub(/(@[a-z_][a-z_0-9]*)/i) { |_| "#{blue}#{$1}#{reset}" }
  end
end
