# frozen_string_literal: true

require "keybase/core"

require_relative "local/exceptions"
require_relative "local/config"
require_relative "local/user"
require_relative "local/kbfs"
require_relative "local/chat"
require_relative "local/team"

module Keybase
  module Local
    VERSION = "1.0.0"

    extend Config
  end
end
