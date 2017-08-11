json.partial! '/taxon_names/base_attributes', taxon_name: taxon_name

if taxon_name.roles.any?
  json.taxon_name_author_roles do
    json.array! taxon_name.taxon_name_author_roles.each do |role|
      json.extract! role, :id, :position
      json.person do
        json.partial! '/people/attributes', person: role.person 
      end
    end
  end
end 


if taxon_name.pinned?(sessions_current_user)
  json.pinboard_item do
    json.id taxon_name.pinboard_item_for(sessions_current_user).id
  end
end

if taxon_name.parent
  json.parent do |parent|
    json.partial! '/taxon_names/base_attributes', taxon_name: taxon_name.parent
  end
end

if taxon_name.origin_citation
  json.origin_citation do
    json.partial! '/citations/attributes', citation: taxon_name.origin_citation
  end
end

if taxon_name.children.any?
  json.children do
    json.array! taxon_name.children.pluck(:id) 
  end
end 

if taxon_name.taxon_name_classifications.any?
  json.taxon_name_classifications do
    json.array! taxon_name.taxon_name_classifications.each do |tc|
      json.partial! '/taxon_name_classifications/attributes', taxon_name_classification: tc 
    end
  end
end

if taxon_name.taxon_name_relationships.any?
  json.taxon_name_relationships do
    json.array! taxon_name.taxon_name_relationships.each do |tr|
      json.partial! '/taxon_name_relationships/attributes', taxon_name_relationship: tr 
    end
  end
end

