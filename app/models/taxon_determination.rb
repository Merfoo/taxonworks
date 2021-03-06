# A Taxon determination is an assertion that a collection object belongs to a taxonomic *concept*.
#
# If you wish to capture verbatim determinations then they should be added to CollectionObject#buffered_determinations,
# i.e. TaxonDeterminations are fully "normalized".
#
# @!attribute biological_collection_object_id
#   @return [Integer]
#   BiologicalCollectionObject, the object being determined
#
# @!attribute otu_id
#   @return [Integer]
#   the OTU (concept) of the determination
#
# @!attribute position
#   @return [Integer]
#     for acts_as_list, !! the determinations with the smallest position is the current/preferred determination,
#     i.e. the one that you want to be seen for the collection object, it is NOT necessarily the most recent
#     determination made
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute year_made
#   @return [Integer]
#     the 4 digit year the determination was made
#
# @!attribute month_made
#   @return [Integer]
#     the month the determination was made
#
# @!attribute day_made
#   @return [Integer]
#   the day of the month the determination was made
#
class TaxonDetermination < ApplicationRecord
  acts_as_list scope: [:biological_collection_object_id]

  include Housekeeping
  include Shared::Citations
  include Shared::DataAttributes
  include Shared::Notes
  include Shared::Confidences
  include Shared::HasRoles
  include Shared::IsData

  belongs_to :otu, inverse_of: :taxon_determinations
  belongs_to :biological_collection_object, class_name: 'CollectionObject', inverse_of: :taxon_determinations, foreign_key: :biological_collection_object_id

  has_many :determiner_roles, class_name: 'Determiner', as: :role_object
  has_many :determiners, through: :determiner_roles, source: :person

  # validates :biological_collection_object, presence: true
  # validates :otu, presence: true # TODO - probably bad, and preventing nested determinations, should just use DB validation

  accepts_nested_attributes_for :determiners 
  accepts_nested_attributes_for :determiner_roles, allow_destroy: true

  # accepts_nested_attributes_for :biological_collection_object
  accepts_nested_attributes_for :otu, allow_destroy: false, reject_if: :reject_otu 

  validates :year_made, date_year: { min_year: 1757, max_year: Time.now.year }
  validates :month_made, date_month: true
  validates :day_made, date_day: {year_sym: :year_made, month_sym: :month_made}, unless: -> {year_made.nil? || month_made.nil?}

  before_save :set_made_fields_if_not_provided
  after_create :sort_to_top

  def sort_to_top
    reload
    self.move_to_top
  end

  def date
    [year_made, month_made, day_made].compact.join("-")
  end

  def sort_date
    Utilities::Dates.nomenclature_date(day_made, month_made, year_made)
  end

  def self.find_for_autocomplete(params)
    where(id: params[:term]).with_project_id(params[:project_id])
  end

  def self.generate_download(scope)
    CSV.generate do |csv|
      csv << column_names
      scope.order(id: :asc).find_each do |o|
        csv << o.attributes.values_at(*column_names).collect { |i|
          i.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
        }
      end
    end
  end

  protected

  def reject_otu(attributed)
    attributed['name'].blank? && attributed['taxon_name_id'].blank?
  end

  def set_made_fields_if_not_provided
    if self.year_made.blank? && self.month_made.blank? && self.day_made.blank?
      self.year_made  = Time.now.year
      self.month_made = Time.now.month
      self.day_made   = Time.now.day
    end
    true
  end

end
