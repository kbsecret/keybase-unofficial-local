# frozen_string_literal: true

require "keybase/core"

require_relative "local/exceptions"
require_relative "local/config"
require_relative "local/user"
require_relative "local/kbfs"
require_relative "local/chat"
require_relative "local/team"

# The primary namespace.
module Keybase
  # The namespace for `keybase-unofficial-local`.
  module Local
    # The current version of `keybase-unofficial-local`.
    VERSION = "0.5.0"

    extend Config

    # there's not much this library can do without keybase actually running
    raise Exceptions::KeybaseNotRunningError unless running?

    # ...or without a logged-in user
    raise Exceptions::KeybaseNotLoggedInError unless logged_in?
  end
end
