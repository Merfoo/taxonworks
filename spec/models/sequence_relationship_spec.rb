require 'rails_helper'

RSpec.describe SequenceRelationship, type: :model, group: [:dna]  do
  let(:sequence_relationship) {SequenceRelationship.new}

  context 'validation' do

    context 'fails when not given' do
      before(:each){
        sequence_relationship.valid?
      }
      
      specify 'subject_sequence' do
        expect(sequence_relationship.errors.include?(:subject_sequence)).to be_truthy
      end

      specify 'object_sequence' do
        expect(sequence_relationship.errors.include?(:object_sequence)).to be_truthy
      end

      specify 'type' do
        expect(sequence_relationship.errors.include?(:type)).to be_truthy
      end
    end

    context 'passes when given' do
      specify 'subject_sequence_id and object_sequence_id and type' do
        sequence_relationship = FactoryBot.create(:valid_sequence_relationship)
        expect(sequence_relationship.valid?).to be_truthy
      end
    end
  end
end
