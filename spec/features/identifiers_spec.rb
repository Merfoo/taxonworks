require 'spec_helper'

describe 'Identifiers' do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /identifiers' do
    before { visit identifiers_path }
    specify 'an index name is present' do
      expect(page).to have_content('Identifiers')
    end
  end
end







