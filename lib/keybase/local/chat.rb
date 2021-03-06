# frozen_string_literal: true

require "open3"
require "json"
require "ostruct"

module Keybase
  module Local
    # Represents Keybase's JSON chat API.
    module Chat
      # The initial arguments to pass when executing Keybase for chatting.
      CHAT_EXEC_ARGS = %w[keybase chat api].freeze

      class << self
        # @param meth [Symbol] the chat method
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

        # Cleans up the object returned by {chat_call}.
        # @param struct [OpenStruct] a structified response from the Keybase chat API
        # @return [OpenStruct] an unwrapped version of the response
        # @raise [Exceptions::ChatError] when the struct contains an error message
        # @api private
        def unwrap(struct)
          raise Exceptions::ChatError, struct.error.message if struct.error

          struct.result
        end

        # Makes chat API calls.
        # @param meth [String, Symbol] the team method
        # @param options [Hash] the options hash
        # @return [OpenStruct] a struct mapping of the JSON response
        # @raise [Exceptions::ChatError] if the chat call fails
        # @api private
        def chat_call(meth, options: {})
          response = Open3.popen3(*CHAT_EXEC_ARGS) do |stdin, stdout, _, _|
            stdin.write envelope meth, options: options
            stdin.close
            stdout.read
          end

          unwrap JSON.parse response, object_class: OpenStruct
        end

        # List the current user's inbox.
        # @param topic_type [String] the topic type to list by
        # @return [OpenStruct] a struct mapping of the JSON response
        # @raise [Exceptions::ChatError] if the chat call fails
        def list_inbox(topic_type: nil)
          chat_call :list, options: {
            topic_type: topic_type,
          }
        end

        # Read a conversation.
        # @param users [Array<String>] a list of the users in the conversation
        # @param peek [Boolean] whether to mark the conversation read
        # @param unread_only [Boolean] whether to fetch unread messages only
        # @return [OpenStruct] a struct mapping of the JSON response
        # @raise [Exceptions::ChatError] if the chat call fails
        def conversation(users, peek: false, unread_only: false)
          chat_call :read, options: {
            channel: {
              name: Core::U[*users],
            },
            peek: peek,
            unread_only: unread_only,
          }
        end

        # Send a message to a conversation. For team-based conversations, see {send_team_message}.
        # @param users [Array<String>] a list of the users in the conversation
        # @param message [String] the message to send
        # @param public [Boolean] whether to send the message to a public channel
        # @param exploding_lifetime [String, nil] how long to wait before exploding the message,
        #   or nil to not explode it
        # @return [OpenStruct] a struct mapping of the JSON response
        # @raise [Exceptions::ChatError] if the chat call fails
        def send_message(users, message, public: false, exploding_lifetime: nil)
          chat_call :send, options: {
            channel: {
              name: Core::U[*users],
              public: public,
            },
            exploding_lifetime: exploding_lifetime,
            message: {
              body: message,
            },
          }
        end

        # Send a message to a team-based conversation. For conversations between individual users,
        # see {send_message}.
        # @param team [String] the name of the team to which the conversation belongs
        # @param topic [String] the conversation's topic
        # @param message [String] the message to send
        # @param exploding_lifetime [String, nil] how long to wait before exploding the message,
        #  or nil to not explode it
        # @return [OpenStruct] a struct mapping of the JSON response
        # @raise [Exceptions::ChatError] if the chat call fails
        def send_team_message(team, topic, message, exploding_lifetime: nil)
          chat_call :send, options: {
            channel: {
              name: team,
              members_type: "team",
              topic_name: topic,
            },
            exploding_lifetime: exploding_lifetime,
            message: {
              body: message,
            },
          }
        end

        # Delete a message from a conversation.
        # @param users [Array<String>] a list of the users in the conversation
        # @param id [Integer] the id of the message to delete
        # @return [OpenStruct] a struct mapping of the JSON response
        # @raise [Exceptions::ChatError] if the chat call fails
        def delete_message(users, id)
          chat_call :delete, options: {
            channel: {
              name: Core::U[*users],
            },
            message_id: id,
          }
        end

        # Edit a message in a conversation.
        # @param users [Array<String>] a list of the users in the conversation
        # @param id [Integer] the id of the message to delete
        # @param message [String] the message to send
        # @return [OpenStruct] a struct mapping of the JSON response
        # @raise [Exceptions::ChatError] if the chat call fails
        def edit_message(users, id, message)
          chat_call :edit, options: {
            channel: {
              name: Core::U[*users],
            },
            message_id: id,
            message: {
              body: message,
            },
          }
        end

        # Upload a file to a conversation.
        # @param users [Array<String>] a list of the users in the conversation
        # @param path [String] the pathname of the file to upload
        # @param title [String] the uploaded file's title
        # @return [OpenStruct] a struct mapping of the JSON response
        # @raise [Exceptions::ChatError] if the chat call fails
        def upload_attachment(users, path, title)
          chat_call :attach, options: {
            channel: {
              name: Core::U[*users],
            },
            filename: path,
            title: title,
          }
        end

        # Download a file from a conversation.
        # @param users [Array<String>] a list of the users in the conversation
        # @param id [Integer] the id of the message to download from
        # @param path [String] the pathname to download to
        # @return [OpenStruct] a struct mapping of the JSON response
        # @raise [Exceptions::ChatError] if the chat call fails
        def download_attachment(users, id, path)
          chat_call :download, options: {
            channel: {
              name: Core::U[*users],
            },
            message_id: id,
            output: path,
          }
        end

        # Make a conversation as read up to a specific ID.
        # @param users [Array<String>] a list of the users in the conversation
        # @param id [Integer] the id of the message to mark up to
        # @return [OpenStruct] a struct mapping of the JSON response
        # @raise [Exceptions::ChatError] if the chat call fails
        def mark_conversation(users, id)
          chat_call :mark, options: {
            channel: {
              name: Core::U[*users],
            },
            message_id: id,
          }
        end

        # Mute a conversation.
        # @param users [Array<String>] a list of the users in the conversation
        # @return [OpenStruct] a struct mapping of the JSON response
        # @raise [Exceptions::ChatError] if the chat call fails
        def mute_conversation(users)
          chat_call :setstatus, options: {
            channel: {
              name: Core::U[*users],
            },
            status: "muted",
          }
        end
      end
    end
  end
end
