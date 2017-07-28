class Tasks::CollectionObjects::BrowseSpecimensController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    otu_id = params[:otu][:id] if params[:otu]
    @otu = nil
    @otu_name = ""
    @gene_name = params[:gene_name]
    @specimens = []

    if otu_id.present?
      @otu = Otu.find_by(id: otu_id)
     @otu_name = ApplicationController.helpers.otu_autocomplete_selected_tag(@otu)
    end

    if @otu.present? && @gene_name.present?
      taxon_determinations = @otu.taxon_determinations
      otu_specimens = []

      taxon_determinations.each do |taxon_determination|
        otu_specimens.push(taxon_determination.biological_collection_object)
      end

      otu_specimens.each do |otu_specimen|
        otu_specimen.origin_relationships.each do |otu_origin_relationship|
          if otu_origin_relationship.new_object_type == "Extract"
            extract = otu_origin_relationship.new_object
            specimen_added = false

            extract.origin_relationships.each do |extract_origin_relationship|
              if extract_origin_relationship.new_object_type == "Sequence"
                sequence = extract_origin_relationship.new_object

                if /#{@gene_name}/.match(sequence.name)
                  @specimens.push(otu_specimen)
                  specimen_added = true
                  break
                end
              end
            end

            break if specimen_added
          end
        end
      end
    end
  end
end
