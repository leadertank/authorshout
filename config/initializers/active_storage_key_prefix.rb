# Prefix Active Storage object keys so files are stored under a folder-like path in S3-compatible buckets.
module ActiveStorageBlobKeyPrefix
  def generate_unique_secure_token(length: ActiveStorage::Blob::MINIMUM_TOKEN_LENGTH)
    token = super(length: length)
    prefix = ENV.fetch("ACTIVE_STORAGE_KEY_PREFIX", "uploads").to_s.gsub(%r{\A/+|/+\z}, "")

    return token if prefix.blank?

    "#{prefix}/#{token}"
  end
end

ActiveSupport.on_load(:active_storage_blob) do
  singleton = ActiveStorage::Blob.singleton_class
  singleton.prepend(ActiveStorageBlobKeyPrefix) unless singleton.ancestors.include?(ActiveStorageBlobKeyPrefix)
end
