class NomenclaturalRank::Iczn::SpeciesGroup::Subspecies < NomenclaturalRank::Iczn::SpeciesGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::SpeciesGroup::Species
  end

  def self.valid_parents
    NomenclaturalRank::Iczn::SpeciesGroup::Species
  end

  def self.abbreviation
    'ssp.'
  end

end
