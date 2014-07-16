class ExhibitSerializer < ActiveModel::Serializer
  attributes :id,
             :subtype,
             :image,
             :image_width,
             :image_height,
             :name,
             :author,
             :year,
             :materials,
             :size,
             :owner
end
