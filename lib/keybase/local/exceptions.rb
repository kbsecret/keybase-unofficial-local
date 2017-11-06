# frozen_string_literal: true

module Keybase
  module Local
    # A namespace for all exceptions defined by {Keybase::Local}.
    module Exceptions
      # Raised if a Keybase installation can't be found.
      class KeybaseNotInstalledError < Core::Exceptions::KeybaseError
        def initialize
          super "keybase needs to be installed"
        end
      end

      # Raised whenever Keybase is not running locally.
      class KeybaseNotRunningError < Core::Exceptions::KeybaseError
        def initialize
          super "keybase needs to be running"
        end
      end

      # Raised whenever KBFS is not running locally.
      class KBFSNotRunningError < Core::Exceptions::KeybaseError
        def initialize
          super "KBFS needs to be enabled and running"
        end
      end

      # Raised whenever a {Keybase::Local::Chat} call fails.
      class ChatError < Core::Exceptions::KeybaseError
        # @param message [String] the error message returned by the API
        def initialize(message)
          super message
        end
      end
    end
  end
end
