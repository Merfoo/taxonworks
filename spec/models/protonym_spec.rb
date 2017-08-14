require 'rails_helper'

describe Protonym, type: :model, group: [:nomenclature, :protonym] do

  before(:all) do
    TaxonNameRelationship.delete_all
    TaxonNameClassification.delete_all
    TaxonName.delete_all
    TaxonNameHierarchy.delete_all
    @order = FactoryGirl.create(:iczn_order)
  end

  after(:all) do
    TaxonNameRelationship.delete_all
    TaxonNameClassification.delete_all
    TaxonName.delete_all
    Citation.delete_all
    Source.destroy_all
    TaxonNameHierarchy.delete_all
  end

  let(:protonym) { Protonym.new }
  let(:root) { Protonym.where(name: 'Root').first  }

  context 'validation' do
    before { protonym.valid? }

    context 'rank_class' do
      specify 'is validly_published when a NomenclaturalRank subclass' do
        protonym.rank_class = Ranks.lookup(:iczn, 'order')
        protonym.name       = 'Aaa'
        protonym.valid?
        expect(protonym.errors.include?(:rank_class)).to be_falsey
      end

      specify 'is invalidly_published when not a NomenclaturalRank subclass' do
        protonym.rank_class = 'foo'
        protonym.valid?
        expect(protonym.errors.include?(:rank_class)).to be_truthy
      end
    end

    specify 'name' do
      expect(protonym.errors.include?(:name)).to be_truthy
    end

    context 'latinization requires' do 
      let(:error_message) {  'Name must be latinized, no digits or spaces allowed' }
      specify 'no digits are present at end' do
        protonym.name = 'aus1'
        protonym.valid?
        expect(protonym.errors.messages[:name]).to include(error_message)
      end

      specify 'no digits are present at start' do
        protonym.name = '1bus'
        protonym.valid?
        expect(protonym.errors.messages[:name]).to include(error_message)
      end

      specify 'no digits are present in middle' do
        protonym.name = 'au1s'
        protonym.valid?
        expect(protonym.errors.messages[:name]).to include(error_message)
      end
        
      specify 'no spaces are present' do
        protonym.name = 'ab us'
        protonym.valid?
        expect(protonym.errors.messages[:name]).to include(error_message)
      end
    end
  end
  
  context 'usage' do
    before(:each) do
      @f = FactoryGirl.create(:relationship_family, name: 'Aidae', parent: @order)
      @g = FactoryGirl.create(:relationship_genus, name: 'Aus', parent: @f)
      @o = FactoryGirl.create(:relationship_genus, name: 'Bus', parent: @f)
      @s = FactoryGirl.create(:relationship_species, name: 'aus', parent: @g)
    end

    specify 'assign an original description genus' do
      expect(@s.original_genus = @o).to be_truthy
      expect(@s.save).to be_truthy
      expect(@s.original_genus_relationship.class).to eq(TaxonNameRelationship::OriginalCombination::OriginalGenus)
      expect(@s.original_genus_relationship.subject_taxon_name).to eq(@o)
      expect(@s.original_genus_relationship.object_taxon_name).to eq(@s)
    end

    specify 'has at most one original description genus' do
      expect(@s.original_combination_relationships.count).to eq(0)
      # Example 1) recasting
      temp_relation = FactoryGirl.build(:taxon_name_relationship,
                                                        subject_taxon_name: @o,
                                                        object_taxon_name: @s,
                                                        type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      temp_relation.save
      # Recast as the subclass
      first_original_genus_relation = temp_relation.becomes(temp_relation.type_class)
      expect(@s.original_combination_relationships.count).to eq(1)

      # Example 2) just use the right subclass to start
      first_original_subgenus_relation = FactoryGirl.build(:taxon_name_relationship_original_combination,
                                                           subject_taxon_name: @g,
                                                           object_taxon_name: @s,
                                                           type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus')
      first_original_subgenus_relation.save
      expect(@s.original_combination_relationships.count).to eq(2)
      extra_original_genus_relation = FactoryGirl.build(:taxon_name_relationship,
                                              subject_taxon_name: @g,
                                              object_taxon_name: @s,
                                              type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus')
      expect(extra_original_genus_relation.valid?).to be_falsey
      extra_original_genus_relation.save
      expect(@s.original_combination_relationships.count).to eq(2)
    end

    specify 'assign a type species to a genus' do
      expect(@g.type_species = @s).to be_truthy
      expect(@g.save).to be_truthy

      expect(@g.type_species_relationship.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@g.type_species_relationship.subject_taxon_name).to eq(@s)
      expect(@g.type_species_relationship.object_taxon_name).to eq(@g)
      expect(@g.type_taxon_name_relationship.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@g.type_taxon_name.name).to eq('aus')
      expect(@s.type_of_relationships.first.class).to eq(TaxonNameRelationship::Typification::Genus)
      expect(@s.type_of_relationships.first.object_taxon_name).to eq(@g)
    end

    specify 'synonym has at most one valid name' do
      genus = FactoryGirl.create(:relationship_genus, name: 'Cus', parent: @f)
      genus.iczn_set_as_subjective_synonym_of = @g
      expect(genus.save).to be_truthy
      genus.iczn_set_as_synonym_of = @o
      expect(genus.save).to be_truthy
      expect(genus.taxon_name_relationships.size).to be(1)
    end
  end

  context 'latinization' do
    let(:invalid_spelling) { Protonym.new(name: '1234', rank_class: Ranks.lookup(:iczn, 'genus'), parent: root) }
    context 'with invalid spelling' do

      specify 'does not #have_latinized_exceptions?' do
        expect(invalid_spelling.has_latinized_exceptions?).to be_falsey
      end

      specify 'is not #is_latin?' do
        expect(invalid_spelling.is_latin?).to be_falsey
      end

      specify '#have_latinized_exceptions?' do
        invalid_spelling.taxon_name_classifications << TaxonName::EXCEPTED_FORM_TAXON_NAME_CLASSIFICATIONS.first.constantize.new
        expect(invalid_spelling.has_latinized_exceptions?).to be_truthy
      end

      context 'when rank ICZN family' do
        let(:family) { Protonym.new(name: 'Fooidae', rank_class: Ranks.lookup(:iczn, 'family'), parent: root) }
        specify "is validly_published when ending in '-idae'" do
          family.valid?
          expect(family.errors.include?(:name)).to be_falsey
        end

        specify "is invalidly_published when not ending in '-idae'" do
          t = Protonym.new(name: 'Aus', rank_class: Ranks.lookup(:iczn, 'family'))
          t.valid?
          expect(t.errors.include?(:name)).to be_truthy
        end

        specify 'is invalidly_published when not capitalized' do
          protonym.name       = 'fooidae'
          protonym.rank_class = Ranks.lookup(:iczn, 'family')
          protonym.valid?
          expect(protonym.errors.include?(:name)).to be_truthy
        end

        specify 'species name starting with upper case' do
          protonym.name       = 'Aus'
          protonym.rank_class = Ranks.lookup(:iczn, 'species')
          protonym.valid?
          expect(protonym.errors.include?(:name)).to be_truthy
        end
      end

      context 'when rank ICN family' do
        specify "is validly_published when ending in '-aceae'" do
          protonym.name       = 'Aaceae'
          protonym.rank_class = Ranks.lookup(:icn, 'family')
          protonym.valid?
          expect(protonym.errors.include?(:name)).to be_falsey
        end
        specify "is invalidly_published when not ending in '-aceae'" do
          protonym.name       = 'Aus'
          protonym.rank_class = Ranks.lookup(:icn, 'family')
          protonym.valid?
          expect(protonym.errors.include?(:name)).to be_truthy
        end
      end
    end

    context 'with valid spelling' do
      before { invalid_spelling.name = 'Aus' }

      specify 'does not #have_latinized_exceptions?' do
        expect(invalid_spelling.has_latinized_exceptions?).to be_falsey
      end

      specify '#is_latin?' do
        expect(invalid_spelling.is_latin?).to be_truthy
      end
    end
  end






  context 'parallel creation of OTUs' do
    let(:p) {Protonym.new(parent: @order , name: 'Aus', rank_class: Ranks.lookup(:iczn, 'genus')) }

    specify '#also_create_otu with new creates an otu after_create' do
      expect(Otu.count).to eq(0) 
      p.also_create_otu = true
      p.save!
      expect(Otu.first.taxon_name_id).to eq(p.id)
    end

    specify '#also_create_otu does not create on save' do
      p.save!
      p.also_create_otu = true
      p.save!
      expect(Otu.count).to eq(0)
    end
  end

end
