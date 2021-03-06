require 'dry-validation'
require 'dry_twitter/operation'

module DryTwitter
  module Post
    class Validate < Operation
      SCHEMA = Dry::Validation.Form do
        configure do
          config.messages_file = Container.root.join("en.yml")

          def session_user_id?(session)
            session.key?(:user_id)
          end
        end

        required(:session).value(:session_user_id?)
        required(:message).filled(max_size?: 128)
      end

      def call(input)
        result = SCHEMA.call(input)

        if result.success?
          Success(input)
        else
          Failure(result.messages)
        end
      end
    end
  end
end