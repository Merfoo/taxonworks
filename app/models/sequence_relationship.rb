class SequenceRelationship < ActiveRecord::Base
  include Housekeeping
  # include Shared::Protocol
  # include Shared::Confidence
  # include Shared::Documentation
  include Shared::Identifiable
  include Shared::IsData
  include Shared::Notable
  include Shared::Taggable

  belongs_to :project
  belongs_to :subject_sequence, polymorphic: true
  belongs_to :object_sequence, polymorphic: true

  validates_presence_of :subject_sequence_id
  validates_presence_of :subject_sequence_type
  validates_presence_of :object_sequence_id
  validates_presence_of :object_sequence_type
  validates_presence_of :relationship_type
  
end
