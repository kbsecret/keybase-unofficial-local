# frozen_string_literal: true

require "json"
require "ostruct"

module Keybase
  module Local
    # Represents an interface to KBFS.
    module KBFS
      # The path to a hidden status file on KBFS.
      # @note The presence of this file is used to determine whether or not the mountpoint
      #  is actually KBFS or just a directory (since an accidental directory at the mountpoint
      #  is unlikely to contain this file).
      KBFS_STATUS_FILE = File.join Config::KBFS_MOUNT, ".kbfs_status"

      class << self
        # @return [Boolean] whether KBFS is currently mounted
        def mounted?
          File.exist? KBFS_STATUS_FILE
        end

        # @return [OpenStruct] a struct mapping of the contents of {KBFS_STATUS_FILE}
        # @raise [Exceptions::KBFSNotRunningError] if KBFS is not mounted
        def status
          raise Exceptions::KBFSNotRunningError unless mounted?
          JSON.parse File.read(KBFS_STATUS_FILE), object_class: OpenStruct
        end
      end
    end
  end
end
