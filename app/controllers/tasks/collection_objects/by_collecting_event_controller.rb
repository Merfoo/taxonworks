class Tasks::CollectionObjects::ByCollectingEventController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    collecting_event_id = params[:collecting_event][:id] if params[:collecting_event]
    @collecting_event = CollectingEvent.find_by(id: collecting_event_id) if collecting_event_id.present?
    @specimens = []

    if @collecting_event.present?
      @specimens = @collecting_event.collection_objects
    end
  end
end
