require 'base64'
require 'fileutils'
require 'gpgme'

module CryptUtils
  def encrypt_secret(plaintext)
    Base64.strict_encode64(plaintext).strip
  end

  def decrypt_eyaml(eyamltext)
    decrypt_gpg(Base64.decode64(eyamltext))
  end

  def decrypt_gpg(ciphertext)
    ctx = GPGME::Ctx.new

    if !ctx.keys.empty?
      raw = GPGME::Data.new(ciphertext)
      txt = GPGME::Data.new

      begin
        txt = ctx.decrypt(raw)
      rescue GPGME::Error::DecryptFailed => e
        raise("Fatal: Failed to decrypt ciphertext (check settings and that you are a recipient). Exception: " + e)
      rescue Exception => e
        raise("Warning: General exception decrypting GPG file. Exception: " + e)
      end

      txt.seek 0
      return txt.read
    else
      raise("No usable keys found in GNUPGHOME")
    end
  end
end

