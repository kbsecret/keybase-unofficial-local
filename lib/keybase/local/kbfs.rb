# frozen_string_literal: true

require "json"
require "ostruct"
require "sys/filesystem"

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
        # @return [Boolean] whether or not KBFS is currently running
        # @note {running?} does *not* mean that KBFS is mounted. For that, see {mounted?}
        def running?
          if Gem.win_platform?
            !`tasklist | find "kbfsfuse.exe"`.empty?
          elsif RUBY_PLATFORM =~ /darwin/
            !`pgrep kbfs`.empty?
          else
            Dir["/proc/[0-9]*/comm"].any? do |comm|
              File.read(comm).chomp == "kbfsfuse" rescue false
            end
          end
        end

        # @return [Boolean] whether or not KBFS is currently mounted
        # @note {mounted?} does *not* mean that KBFS is fully functional. For that, see
        #  {functional?}
        def mounted?
          Sys::Filesystem.mounts.any? { |m| m.mount_point == Config::KBFS_MOUNT }
        end

        # @return [Boolean] whether or not KBFS is currently fully functional
        # @note The criteria for being "functional" is as follows:
        #  1. Keybase is running
        #  2. KBFS is running
        #  3. {KBFS_MOUNT} is mounted
        def functional?
          Local.running? && running? && mounted?
        end

        # @return [OpenStruct] a struct mapping of the contents of {KBFS_STATUS_FILE}
        # @raise [Exceptions::KBFSNotRunningError] if KBFS is not functional
        def status
          raise Exceptions::KBFSNotRunningError unless functional?
          JSON.parse File.read(KBFS_STATUS_FILE), object_class: OpenStruct
        end
      end
    end
  end
end
