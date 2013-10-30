class Person < ActiveRecord::Base

  validates_presence_of :last_name, :type
  before_validation :set_type_if_blank
  validates :type, inclusion: { in: ['Person::Vetted', 'Person::Unvetted'],
                                message: "%{value} is not a validly_published type" }

  has_many :roles 
  has_many :author_roles, class_name: 'Role::SourceAuthor'
  has_many :editor_roles, class_name: 'Role::SourceEditor'
  has_many :human_roles, class_name: 'Role::SourceSource'
  has_many :collector_roles, class_name: 'Role::Collector'

  has_many :authored_sources, through: :author_roles, source: :role_object, source_type: 'Source::Bibtex'
  has_many :edited_sources, through: :editor_roles, source: :role_object, source_type: 'Source::Bibtex'
  has_many :source_sources, through: :human_roles, source: :role_object, source_type: 'Source::Human'
  has_many :collecting_events, through: :collectors, source: :role_object, source_type: 'CollectingEvent'
  has_many :taxon_determinations, through: :determiners, source: :role_object, source_type: 'TaxonDetermination'
  has_many :taxon_name_authors, through: :taxon_name_authors, source: :role_object, source_type: 'TaxonName'
  has_many :type_specimens, through: :type_designations, source: :role_object, source_type: 'TypeDesignation'

  def name 
    [self.first_name, self.prefix, self.last_name, self.suffix].compact.join(' ')
  end

  def is_author?
    self.author_roles.to_a.length > 0
  end

  def is_editor?
    self.editor_roles.to_a.length > 0
  end

  protected

  def set_type_if_blank
    self.type ||= 'Person::Unvetted'
  end

end

