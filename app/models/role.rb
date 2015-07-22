# A Role relates a Person (a Person is data in TaxonWorks) to other data.
#
class Role < ActiveRecord::Base

  TYPE_INFLECTIONS = {
    author: 'SourceAuthor',
    editor: 'SourceEditor',
    collector: 'Collector',
    source: 'SourceSource'
  }

  include Housekeeping::Users
  include Shared::IsData

  acts_as_list scope: [:type, :role_object_type, :role_object_id]

  belongs_to :role_object, polymorphic: :true, validate: true
  belongs_to :person, inverse_of: :roles, validate: true
  accepts_nested_attributes_for :person, reject_if: :all_blank, allow_destroy: true
  # Note:
  # - acts_as_list adds :position in a manner that can not be validated with validate_presence_of
  # - role_object is required but at the database constraint level at present
  validates_presence_of :type
  validates :person, presence: true
  # validates :role_object, presence: true

  validates_uniqueness_of :person_id, scope: [:role_object_id, :role_object_type, :type]

  # after save :vet_people

  protected

  def vet_person
    # if a person is ever used in 2 different roles they are considered vetted.
    #TODO write test for this
    if Role.where(person_id: person_id).count > 1
      p = Person.find(person_id)
      p.update(type: 'Person::Vetted')
    end
  end
end
