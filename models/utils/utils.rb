require 'digest/sha2'
require 'mail'

module Utils
# This Hasher module - hashes user passwords
  module Hasher
    def Hasher.hash_password(password, salt)
      Digest::SHA2.hexdigest(password + salt)
    end

    def Hasher.generate_salt
      random = Random.new
      Array.new(User.salt.length){random.rand(33...126).chr}.join
    end
  end

# Check if this works on your server
  module Mailer
    def Mailer.send_to_user(user, message, subject, settings)
      to_mail = user.email
      fr_mail = settings.email

      mail = Mail.new do
        from fr_mail
        to to_mail
        subject subject
        body message
      end
      mail.deliver if settings.send_notifications
    end
  end

end