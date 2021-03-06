require 'dry_twitter/import'
require 'dry-monads'
require 'dry_twitter/operation'
require 'rom/sql/error'

module DryTwitter
  module Users
    class PersistFollowStatus < Operation
      include DryTwitter::Import["repositories.followed_users"]
      include Dry::Monads::Try::Mixin

      def call(input)
        result = Try(ROM::SQL::Error) {
          user_id = input[:user_id]
          followed_user_id = input[:followed_user_id]
          followed_user = followed_users.followed_user(user_id, followed_user_id)
          if followed_user
            followed_users.delete(followed_user["id"])
          else
            followed_users.create(user_id: user_id, followed_user_id: followed_user_id)
          end

          user_id
        }

        if result.value?
          Success(result.value)
        else
          Failure(error_messages: [result.exception.message])
        end
      end
    end
  end
end
