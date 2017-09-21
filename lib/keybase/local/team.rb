# frozen_string_literal: true

require "open3"
require "json"

module Keybase
  module Local
    # Represents an interface to Keybase's teams.
    module Team
      # The initial arguments to pass when executing Keybase for team management.
      TEAM_EXEC_ARGS = %w[keybase team].freeze

      # The pattern used to (partially) validate team names.
      # @see https://github.com/keybase/client/blob/5aa02d1b351f0dfab050eb5ae22bffdf59f61d91/go/protocol/keybase1/extras.go#L1560
      TEAM_PATTERN = /([a-zA-Z0-9][a-zA-Z0-9_]?)+/

      class << self
        # @param args [Array<String>] additional arguments to pass to `keybase team`
        # @param payload [String, nil] input data to feed to the invocation
        # @param json [Boolean] whether or not to parse `stdout` as JSON
        # @return [Hash, Boolean, nil] the parsed JSON, or a true/false/nil result indicating
        #   command success
        # @api private
        def team_call(*args, payload: nil, json: false)
          if json
            response = Open3.popen3(*TEAM_EXEC_ARGS, *args) do |stdin, stdout, _, _|
              stdin.write payload if payload
              stdin.close # close after writing to let keybase know we're done
              stdout.read
            end

            if response.empty?
              {}
            else
              JSON.parse response
            end
          else
            system(*TEAM_EXEC_ARGS, *args)
          end
        end

        # Create a new Keybase team.
        # @note This is a stub.
        # @api private
        def create(_team)
          # stub
        end

        # Add a user to a Keybase team.
        # @note This is a stub.
        # @api private
        def add_member(_team, _user, _role: :reader, _email: false)
          # stub
        end

        # Remove a user from a Keybase team.
        # @note This is a stub.
        # @api private
        def remove_member(_team, _user)
          # stub
        end

        # Modify a user in a Keybase team.
        # @note This is a stub.
        # @api private
        def edit_member(_team, _user, _role: :reader)
          # stub
        end

        # List all teams currently belonged to.
        # @param force_poll [Boolean] whether or not to force a poll of the server for all idents
        # @return [Hash] a hash representation of all teams currently belonged to
        def list_memberships(force_poll: false)
          args = %w[list-memberships --json]
          args << "--force-poll" if force_poll

          team_call(*args, json: true)
        end

        # List all members of the given team.
        # @param force_poll [Boolean] whether or not to force a poll of the server for all idents
        # @return [Hash] a hash representation of all members of the given team
        def list_members(team, force_poll: false)
          args = %W[list-members #{team} --json]
          args << "--force-poll" if force_poll

          team_call(*args, json: true)
        end

        # Change the name of a Keybase team.
        # @note This is a stub.
        # @api private
        def rename(_old_team, _new_team)
          # stub
        end

        # Request access to a Keybase team.
        # @note This is a stub.
        # @api private
        def request_access(_team)
          # stub
        end

        # List requests to join Keybase teams.
        # @note This is a stub.
        # @api private
        def list_requests
          # stub
        end

        # Ignore a request to join a Keybase team.
        # @note This is a stub.
        # @api private
        def ignore_request(_team, _user)
          # stub
        end

        # Accept an email invitation to join a Keybase team.
        # @note This is a stub.
        # @api private
        def accept_invite(_token)
          # stub
        end

        # Leave a Keybase team.
        # @note This is a stub.
        # @api private
        def leave(_team, _permanent: false)
          # stub
        end

        # Delete a Keybase team.
        # @note This is a stub.
        # @api private
        def delete(_team)
          # stub
        end
      end
    end
  end
end
