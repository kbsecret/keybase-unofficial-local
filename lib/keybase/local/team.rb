# frozen_string_literal: true

require "open3"
require "json"
require "ostruct"

module Keybase
  module Local
    # Represents Keybase's JSON team API.
    module Team
      # The initial arguments to pass when executing Keybase for team management.
      TEAM_EXEC_ARGS = %w[keybase team api].freeze

      class << self
        # @param meth [Symbol] the team method
        # @param options [Hash] the options hash
        # @return [String] the JSON serialized envelope
        # @api private
        def envelope(meth, options: {})
          {
            method: meth,
            params: {
              options: options,
            },
          }.to_json
        end

        # Makes team API calls.
        # @param meth [String, Symbol] the team method
        # @param options [Hash] the options hash
        # @return [OpenStruct] a struct mapping on the JSON response
        # @api private
        def team_call(meth, options: {})
          response = Open3.popen3(*TEAM_EXEC_ARGS) do |stdin, stdout, _, _|
            stdin.write envelope meth, options: options
            stdin.close
            stdout.read
          end

          JSON.parse response, object_class: OpenStruct
        end

        # List all team memberships for the current user.
        # @return [OpenStruct] a struct mapping of the JSON response
        def list_self_memberships
          team_call "list-self-memberships"
        end

        alias self_memberships list_self_memberships

        # List all users in the given team.
        # @param team [String] the team to list
        # @return [OpenStruct] a struct mapping of the JSON response
        def list_team_memberships(team)
          team_call "list-team-memberships", options: {
            team: team,
          }
        end

        alias team_memberships list_team_memberships

        # List teams for a user.
        # @param user [String] a Keybase username
        # @return [OpenStruct] a struct mapping of the JSON response
        def list_user_memberships(user)
          team_call "list-user-memberships", options: {
            username: user,
          }
        end

        alias user_memberships list_user_memberships

        # Create a new team.
        # @param team [String] the team name
        # @return [OpenStruct] a struct mapping of the JSON response
        def create_team(team)
          team_call "create-team", options: {
            team: team,
          }
        end

        # Add members to a team.
        # @param team [String] the team name
        # @param emails [Array<Hash>] a list of email-role hashes to add to the team
        # @param users [Array<Hash>] a list of Keybase user-role hashes to add to the team
        # @return [OpenStruct] a struct mapping of the JSON response
        # @example
        #  Keybase::Local::Team.add_members "foo", users: [{ username: "bob", role: "reader" }]
        #  Keybase::Local::Team.add_members "bar", emails: [{ email: "foo@bar.com", role: "admin" }]
        def add_members(team, emails: [], users: [])
          team_call "add-members", options: {
            team: team,
            emails: emails,
            usernames: users,
          }
        end

        # Edit the role of a user on a team.
        # @param team [String] the team name
        # @param user [String] the Keybase user to edit
        # @param role [String] the user's new role
        # @return [OpenStruct] a struct mapping of the JSON response
        # @example
        #  Keybase::Local::Team.edit_member "foo", "bob", "reader"
        def edit_member(team, user, role)
          team_call "edit-member", options: {
            team: team,
            username: user,
            role: role,
          }
        end

        # Remove a user from a team.
        # @param team [String] the team name
        # @param user [String] the Keybase user to remove
        # @return [OpenStruct] a struct mapping of the JSON response
        def remove_member(team, user)
          team_call "remove-member", options: {
            team: team,
            username: user,
          }
        end

        # Rename a subteam.
        # @param old_name [String] the subteam's current name
        # @param new_name [String] the subteam's new name
        # @return [OpenStruct] a struct mapping of the JSON response
        # @example
        #  Keybase::Local::Team.rename_subteam "foo.bar", "foo.baz"
        def rename_subteam(old_name, new_name)
          team_call "rename-subteam", options: {
            team: old_name,
            "new-team-name": new_name,
          }
        end

        # Leave a team.
        # @param team [String] the team name
        # @param permanent [Boolean] whether or not to leave the team permanently
        # @return [OpenStruct] a struct mapping of the JSON response
        def leave_team(team, permanent: false)
          team_call "leave-team", options: {
            team: team,
            permanent: permanent,
          }
        end
      end
    end
  end
end
