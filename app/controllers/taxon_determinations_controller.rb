class TaxonDeterminationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_taxon_determination, only: [:show, :edit, :update, :destroy]

  # GET /taxon_determinations
  # GET /taxon_determinations.json
  def index
    @recent_objects = TaxonDetermination.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  def list
    @taxon_determinations = TaxonDetermination.with_project_id($project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  # GET /taxon_determinations/1
  # GET /taxon_determinations/1.json
  def show
  end

  # GET /taxon_determinations/new
  def new
    @taxon_determination = TaxonDetermination.new
  end

  # GET /taxon_determinations/1/edit
  def edit
  end

  # POST /taxon_determinations
  # POST /taxon_determinations.json
  def create
    @taxon_determination = TaxonDetermination.new(taxon_determination_params)

    respond_to do |format|
      if @taxon_determination.save
        format.html { redirect_to @taxon_determination, notice: 'Taxon determination was successfully created.' }
        format.json { render action: 'show', status: :created, location: @taxon_determination }
      else
        format.html { render action: 'new' }
        format.json { render json: @taxon_determination.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /taxon_determinations/1
  # PATCH/PUT /taxon_determinations/1.json
  def update
    # byebug
    respond_to do |format|
      if @taxon_determination.update(taxon_determination_params)
        format.html { redirect_to @taxon_determination, notice: 'Taxon determination was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @taxon_determination.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxon_determinations/1
  # DELETE /taxon_determinations/1.json
  def destroy
    @taxon_determination.destroy
    respond_to do |format|
      format.html { redirect_to taxon_determinations_url }
      format.json { head :no_content }
    end
  end

  # GET /taxon_determinations/search
  def search
    if params[:id].blank?
      redirect_to taxon_determination_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to taxon_determination_path(params[:id])
    end
  end

  def autocomplete
    @taxon_determinations = taxon_determination.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))
    data = @taxon_determinations.collect do |t|
      {id: t.id,
       label: TaxonDeterminationsHelper.taxon_determination_tag(t),
       response_values: {
           params[:method] => t.id
       },
       label_html: TaxonDeterminationsHelper.taxon_determination_tag(t) #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end

    render :json => data
  end

  # GET /taxon_determinations/download
  def download
    send_data TaxonDetermination.generate_download( TaxonDetermination.where(project_id: $project_id) ), type: 'text', filename: "taxon_determinations_#{DateTime.now.to_s}.csv"
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_taxon_determination
      @taxon_determination = TaxonDetermination.with_project_id($project_id).find(params[:id])
      @recent_object       = @taxon_determination
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def taxon_determination_params
      params.require(:taxon_determination).permit(
        :biological_collection_object_id, :otu_id, :year_made, :month_made, :day_made,
        roles_attributes: [:id, :_destroy, :type, :person_id, :position, person_attributes: [:last_name, :first_name, :suffix, :prefix]],
        otu_attributes: [:id, :_destroy, :name, :taxon_name_id]
      )
    end
end
