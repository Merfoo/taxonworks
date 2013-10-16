class NomenclaturalRank::Icn::GenusGroup::Subsection < NomenclaturalRank::Icn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Icn::GenusGroup::Section
  end

  def self.available_parents
    NomenclaturalRank::Icn::GenusGroup::Section
  end

  def self.abbreviation
    "subsect."
  end
end
