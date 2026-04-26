class User < ApplicationRecord
  attr_accessor :human_verification

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy
  has_many :book_likes, dependent: :destroy

  validates :human_verification, acceptance: {
    accept: "1",
    message: "must be checked before creating an account"
  }, on: :create

  after_create :create_default_profile

  scope :admins_first, -> { order(admin: :desc, created_at: :asc) }

  def display_name
    full_name.presence || email.to_s.split("@").first.titleize
  end

  def full_name
    [ first_name, last_name ].join(" ").squish
  end

  private

  def create_default_profile
    create_profile!
  end
end
