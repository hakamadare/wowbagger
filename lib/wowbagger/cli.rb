require 'gli'

module Wowbagger
  class CLI

    include GLI::App

    def self.main

      version Wowbagger::VERSION

      exit run(ARGV)
    end

  end
end
