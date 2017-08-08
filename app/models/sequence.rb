require_dependency 'sequence_relationship'

# A DNA, RNA, or Amino Acid, as defined by a string of letters.
# All other attributes are stored in related tables, the overal model is basically a graph with nodes having attributes.
#
# @!attribute sequence 
#   @return [String]
#     the letters representing the sequence 
#
# @!attribute sequence_type
#   @return [String]
#     one of "DNA", "RNA", "AA"
#
# @!attribute name 
#   @return [String]
#     the _asserted_ name for this sequence, typically the target gene name like "CO1".  
#     Important! The preferred mechanism for assinging this type of label to a sequence is 
#     assigning pertinent metadata (relationships to other sequences) and then
#     inferrning that those sequences with particular metadata have a 
#     specific gene name (Descriptor::Gene#name).  
#
class Sequence < ActiveRecord::Base

  include Housekeeping

  include Shared::AlternateValues
  include Shared::DataAttributes
  include Shared::Confidence
  include Shared::Documentation
  include Shared::Identifiable
  include Shared::IsData
  include Shared::Notable
  include Shared::OriginRelationship
  include Shared::Protocols
  include Shared::Taggable

  is_origin_for 'Sequence'
  has_paper_trail

  ALTERNATE_VALUES_FOR = [:name]

  # Pass a Gene::Descriptor instance to clone that description to this sequence
  attr_accessor :describe_with

  has_many :sequence_relationships, foreign_key: :subject_sequence_id, inverse_of: :subject_sequence # this sequence describes others 
  has_many :sequences, through: :sequence_relationships, source: :object_sequence

  has_many :related_sequence_relationships, class_name: 'SequenceRelationship', foreign_key: :object_sequence_id, inverse_of: :object_sequence # attributes of this sequence
  has_many :related_sequences, through: :related_sequence_relationships, source: :subject_sequence
  has_many :gene_attributes, inverse_of: :sequences

  # has_many :descriptors, through: :gene_attributes, inverse_of: :sequences, as: 'Descriptor::Gene'

  before_validation :build_relationships, if: 'describe_with.present?'
  before_validation :normalize_sequence_type

  SequenceRelationship.descendants.each do |d|
    t = d.name.demodulize.tableize.singularize
    relationships = "#{t}_relationships".to_sym
    sequences = "#{t}_sequences".to_sym

    has_many relationships, class_name: d.name.to_s, foreign_key: :object_sequence_id, inverse_of: :object_sequence
    has_many sequences, class_name: 'Sequence', through: relationships, source: :subject_sequence, inverse_of: :sequences

    accepts_nested_attributes_for sequences
    accepts_nested_attributes_for relationships 
  end

  validates_presence_of :sequence
  validates_inclusion_of :sequence_type, in: ["DNA", "RNA", "AA"]

  protected

  def build_relationships
    describe_with.gene_attributes.each do |ga|
      related_sequence_relationships.build(subject_sequence: ga.sequence, type: ga.sequence_relationship_type)
    end
  end

  def normalize_sequence_type
    sequence_type.to_s.upcase! if sequence_type.present?
  end

end


