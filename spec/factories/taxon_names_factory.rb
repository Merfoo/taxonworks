FactoryGirl.define do
  factory :taxon_name do
    factory :valid_taxon_name, traits: [:housekeeping]  do
      association :parent, factory: :root_taxon_name
      name 'Adidae'
      rank_class Ranks.lookup(:iczn, 'Family')
    end
  end
end
