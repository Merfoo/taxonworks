class TaxonNameRelationship::Iczn::Invalidating < TaxonNameRelationship::Iczn

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000272'

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Validating)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_descendants_to_s(TaxonNameClassification::Iczn::Available::Valid) +
        self.collect_to_s(TaxonNameClassification::Iczn::Available,
            TaxonNameClassification::Iczn::Available::OfficialListOfFamilyGroupNamesInZoology,
            TaxonNameClassification::Iczn::Available::OfficialListOfGenericNamesInZoology,
            TaxonNameClassification::Iczn::Available::OfficialListOfWorksApprovedAsAvailable)
  end

  def self.nomenclatural_priority
    :direct
  end

  def self.assignable
    true
  end

  def subject_properties
    [ TaxonNameClassification::Iczn::Available::Invalid ]
  end


  def subject_status
    'invalid'
  end

  def object_status
    'valid'
  end

  def subject_status_connector_to_object
    ', linked to'
  end

  def object_status_connector_to_subject
    ' for'
  end


  def self.gbif_status_of_subject
    'invalidum'
  end


  # as.
  def self.assignment_method
    # bus.set_as_iczn_invalid_of(aus)
    :iczn_set_as_invalid_of
  end

  def self.inverse_assignment_method
    # aus.iczn_invalid = bus   ## Equal to synonym in broad sense
    :iczn_invalid
  end
end
