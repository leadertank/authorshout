class SupportMessage
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :email, :string
  attribute :message, :string
  attribute :human_verification, :string
  attribute :organization_name, :string

  validates :name, presence: true, length: { maximum: 120 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, length: { maximum: 4000 }
  validates :human_verification, acceptance: {
    accept: "1",
    message: "must be checked to verify you are human"
  }
  validates :organization_name, absence: true
end
