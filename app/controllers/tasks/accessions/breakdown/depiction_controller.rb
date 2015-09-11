
class Tasks::Accessions::Breakdown::DepictionController < ApplicationController
  include TaskControllerConfiguration

  # GET /tasks/accession/breakdown/depiction/:id
  def index
    @result = SqedToTaxonworks::Result.new(
      depiction_id:  params[:depiction_id],
      user_id: @sessions_current_user_id,
      project_id: @sessions_current_project_id,
    )
  end

  def update 
    @depiction = Depiction.find(params[:id])
    
    if @depiction.depiction_object.update(collection_object_params)
      flash[:notice] = 'Successfully updated'
    else
      flash[:alert] = 'Failed to update! ' + @depiction.depiction_object.errors.full_messages.join("; ").html_safe
    end
    redirect_to depiction_breakdown_task_path(@depiction)
  end

  def collection_object_params
    params.require(:collection_object).permit(
      :buffered_collecting_event, :buffered_other_labels, :buffered_determinations,
      identifiers_attributes: [:id, :namespace_id, :identifier, :type, :_destroy],
      taxon_determinations_attributes: [:otu_id, :_destroy]
    )
  end


end
