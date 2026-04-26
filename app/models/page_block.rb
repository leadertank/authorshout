class PageBlock < ApplicationRecord
  belongs_to :page

  KINDS = %w[hero text image code button callout cta].freeze
  THEMES = %w[default accent muted dark].freeze
  COLUMN_SPANS = [ 12, 8, 6, 4, 3 ].freeze
  ROW_COLUMNS = [ 1, 2, 3, 4, 5 ].freeze
  COLUMN_SLOTS = [ 1, 2, 3, 4, 5 ].freeze
  TEXT_ALIGNS = %w[left center right].freeze
  BACKGROUND_STYLES = %w[card outline split full].freeze
  SECTION_SPACINGS = %w[sm md lg].freeze

  validates :kind, inclusion: { in: KINDS }
  validates :theme, inclusion: { in: THEMES }, allow_blank: true
  validates :column_span, inclusion: { in: COLUMN_SPANS }
  validates :row_columns, inclusion: { in: ROW_COLUMNS }
  validates :column_slot, inclusion: { in: COLUMN_SLOTS }
  validates :row_number, numericality: { only_integer: true, greater_than: 0 }
  validates :text_align, inclusion: { in: TEXT_ALIGNS }
  validates :background_style, inclusion: { in: BACKGROUND_STYLES }
  validates :section_spacing, inclusion: { in: SECTION_SPACINGS }
  validates :button_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true
  validates :media_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true
  validate :column_slot_within_row_columns

  before_validation :set_defaults

  private

  def set_defaults
    self.kind = kind.presence || "text"
    self.theme = theme.presence || "default"
    self.column_span ||= 12
    self.row_number ||= 1
    self.row_columns ||= 1
    self.column_slot ||= 1
    self.text_align = text_align.presence || "left"
    self.background_style = background_style.presence || "card"
    self.section_spacing = section_spacing.presence || "md"
  end

  def column_slot_within_row_columns
    return if column_slot.blank? || row_columns.blank?
    return if column_slot <= row_columns

    errors.add(:column_slot, "must be within the row column count")
  end
end
