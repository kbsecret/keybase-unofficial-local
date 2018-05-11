# frozen_string_literal: true

require "json"

module Keybase
  module Local
    # Methods and constants related to a local Keybase installation.
    module Config
      # The Keybase configuration directory.
      CONFIG_DIR = if Gem.win_platform?
                     File.expand_path("#{ENV["LOCALAPPDATA"]}/Keybase").freeze
                   elsif RUBY_PLATFORM =~ /darwin/
                     File.expand_path("~/Library/Application Support/Keybase").freeze
                   else
                     File.expand_path("~/.config/keybase").freeze
                   end

      # The Keybase configuration file.
      # @note This is not guaranteed to exist on disk.
      CONFIG_FILE = File.join(CONFIG_DIR, "config.json").freeze

      # The Keybase status hash, obtained from `keybase status -j`.
      STATUS_HASH = JSON.parse(`keybase status -j`)

      # The mountpoint for KBFS.
      KBFS_MOUNT = File.realpath "/keybase"

      # @return [String] the currently logged-in user
      def current_user
        STATUS_HASH["Username"]
      end

      # @return [String] the user's private KBFS directory
      def private_dir
        File.join(KBFS_MOUNT, "private", current_user)
      end

      # @return [String] the user's public KBFS directory
      def public_dir
        File.join(KBFS_MOUNT, "public", current_user)
      end

      # @return [Boolean] whether or not Keybase is currently running
      def running?
        if Gem.win_platform?
          !`tasklist | find "keybase.exe"`.empty?
        elsif RUBY_PLATFORM =~ /darwin/
          !`pgrep keybase`.empty?
        else
          # is there a more efficient way to do this that doesn't involve an exec?
          Dir["/proc/[0-9]*/comm"].any? do |comm|
            File.read(comm).chomp == "keybase" rescue false # hooray for TOCTOU
          end
        end
      end

      def logged_in?
        STATUS_HASH["LoggedIn"]
      end

      # @return [String] the running Keybase's version string
      # @raise [Exceptions::KeybaseNotRunningError] if Keybase is not running
      def running_version
        raise Exceptions::KeybaseNotRunningError unless running?
        `keybase --version`.split[2]
      end
    end
  end
end
