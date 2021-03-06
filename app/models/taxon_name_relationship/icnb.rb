class TaxonNameRelationship::Icnb < TaxonNameRelationship

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000231'

  validates_uniqueness_of :subject_taxon_name_id, scope: [:type, :object_taxon_name_id]

  # left_side
  def self.valid_subject_ranks
    ::ICNB
  end

  # right_side
  def self.valid_object_ranks
    ::ICNB
  end

  def self.disjoint_subject_classes
    ICZN_TAXON_NAME_CLASSIFICATION_NAMES + ICN_TAXON_NAME_CLASSIFICATION_NAMES
  end

  def self.disjoint_object_classes
    ICZN_TAXON_NAME_CLASSIFICATION_NAMES + ICN_TAXON_NAME_CLASSIFICATION_NAMES +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icnb::NotEffectivelyPublished,
                                                 TaxonNameClassification::Icnb::EffectivelyPublished::InvalidlyPublished,
                                                 TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Illegitimate)
  end

end