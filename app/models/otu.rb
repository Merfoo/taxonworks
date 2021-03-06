# An Otu (loosely, operational taxonomic unit) can be thought of as a unit of study.  In most cases an otu is a taxon.
#
# An Otu is defined by its underlying data and may be labeled with a name (TaxonName). Otus are used to represent rows
# in matrices, taxon pages, individuals or populations, or arbitrary clusters of organisms (e.g. 'unsorted specimens in this container').
# Otus are a primary unit of work in TaxonWorks.
#
# OTU is labeled with a name, either arbitrarily given or specifically linked to a taxon_name_id.
#
# @!attribute name
#   @return [String]
#   A label for the OTU.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute taxon_name_id
#   @return [Integer]
#   The id of the nomenclatural name for this OTU.  The presence of a nomenclatural name carries no biological meaning, it is
#   simply a means to organize concepts within a nomenclatural system.
#
#
# TODO Semantics vs. taxon_name_id
#
class Otu < ApplicationRecord
  include Housekeeping
  include SoftValidation
  #include Shared::AlternateValues  # 1/26/15 with MJY - not going to allow alternate values in Burlap
  include Shared::Citations           # TODO: have to think hard about this vs. using Nico's framework
  include Shared::DataAttributes
  include Shared::Identifiers
  include Shared::Notes
  include Shared::Tags
  include Shared::Depictions
  include Shared::Loanable
  include Shared::Confidences
  include Shared::HasPapertrail
  include Shared::IsData

  belongs_to :taxon_name, inverse_of: :otus

  has_many :asserted_distributions, inverse_of: :otu

  has_many :taxon_determinations, inverse_of: :otu, dependent: :destroy
  has_many :collection_objects, through: :taxon_determinations, source: :biological_collection_object, inverse_of: :otus

  has_many :collecting_events, -> {distinct}, through: :collection_objects

  has_many :common_names, dependent: :destroy
  has_many :collection_profiles # @proceps dependent: what?
  has_many :contents, inverse_of: :otu, dependent: :destroy
  has_many :geographic_areas_from_asserted_distributions, through: :asserted_distributions, source: :geographic_area
  has_many :geographic_areas_from_collecting_events, through: :collecting_events, source: :geographic_area
  has_many :georeferences, through: :collecting_events

  has_many :observations, inverse_of: :otu
  has_many :descriptors, through: :observations

  has_many :content_topics, through: :contents, source: :topic

  scope :with_taxon_name_id, -> (taxon_name_id) { where(taxon_name_id: taxon_name_id) }
  scope :with_name, -> (name) { where(name: name) }

  # @return scope
  def self.self_and_descendants_of(otu_id)
    o = Otu.includes(:taxon_name).find(otu_id)
    if o && o.taxon_name
      with_taxon_name_id(Otu.find(otu_id).taxon_name.self_and_descendants)
    else
      Otu.where(id: otu_id)
    end
  end

  validate :check_required_fields

  soft_validate(:sv_taxon_name, set: :taxon_name)
  soft_validate(:sv_duplicate_otu, set: :duplicate_otu)

  accepts_nested_attributes_for :common_names, allow_destroy: true

  #region class methods

  # return [Scope] the otus bound to that taxon name and its descendants
  def self.for_taxon_name(taxon_name)
    if taxon_name.kind_of?(String) || taxon_name.kind_of?(Integer)
      tn = TaxonName.find(taxon_name)
    else
      tn = taxon_name
    end
    Otu.joins(taxon_name: [:ancestor_hierarchies]).where(taxon_name_hierarchies: {ancestor_id: tn.id} )
  end

  # TODO: This need to be renamed to reflect "simple" association
  def self.batch_preview(file: nil, ** args)
    # f     = CSV.read(file, headers: true, col_sep: "\t", skip_blanks: true, header_converters: :symbol)
    @otus = []
    File.open(file).each do |row|
      name = row.strip
      next if name.blank?
      @otus.push(Otu.new(name: row.strip))
    end
    @otus
  end

  def self.batch_create(otus: {}, ** args)
    new_otus = []
    begin
      Otu.transaction do
        otus.keys.each do |k|
          o = Otu.new(otus[k])
          o.save!
          new_otus.push(o)
        end
      end
    rescue
      return false
    end
    new_otus
  end

  #endregion

  #region instance methods
  # Hernán - this is extremely hacky, I'd like to
  # map core keys to procs, use yield:, use cached values,
  # add logic for has_many handling (e.g. identifiers) etc.
  # ultmately, each key maps to a proc that returns a value
  #
  # deprecated for new approach in CollectionObject, AssertedDistribution
  def dwca_core
    core = Dwca::GbifProfile::CoreTaxon.new

    core.nomenclaturalCode        = (taxon_name.rank_class.nomenclatural_code.to_s.upcase)
    core.taxonomicStatus          = (taxon_name.unavailable_or_invalid? ? nil : 'accepted')
    core.nomenclaturalStatus      = (taxon_name.classification_invalid_or_unavailable? ? nil : 'available') # needs tweaking
    core.scientificName           = taxon_name.cached
    core.scientificNameAuthorship = taxon_name.cached_author_year
    core.scientificNameID         = taxon_name.identifiers.first.identifier
    core.taxonRank                = taxon_name.rank
    core.namePublishedIn          = taxon_name.source.cached
    core
  end

  def otu_name
    if !name.blank?
      name
    elsif !self.taxon_name_id.nil?
      self.taxon_name.cached_html_name_and_author_year
    else
      nil
    end
  end

  def distribution_geoJSON
    a_ds   = Gis::GeoJSON.feature_collection(geographic_areas_from_asserted_distributions, :asserted_distributions)
    c_os   = Gis::GeoJSON.feature_collection(collecting_events, :collecting_events_georeferences)
    c_es   = Gis::GeoJSON.feature_collection(geographic_areas_from_collecting_events, :collecting_events_geographic_area)
    retval = Gis::GeoJSON.aggregation([a_ds, c_os, c_es], :distribution)
    retval
  end

  protected

  def check_required_fields
    if taxon_name_id.blank? && name.blank?
      errors.add(:taxon_name_id, 'and/or name should be selected')
      errors.add(:name, 'and/or taxon name should be selected')
    end
  end

  def sv_taxon_name
    soft_validations.add(:taxon_name_id, 'Taxon is not selected') if self.taxon_name_id.nil?
  end

  def sv_duplicate_otu
    unless Otu.with_taxon_name_id(self.taxon_name_id).with_name(self.name).not_self(self).with_project_id(self.project_id).empty?
      soft_validations.add(:taxon_name_id, 'Duplicate Taxon and Name combination')
      soft_validations.add(:name, 'Duplicate Taxon and Name combination')
    end
  end

  # def collecting_event_geoJSON
  #   Gis::GeoJSON.feature_collection(collecting_events, :collecting_events)
  # end
  #endregion
end



