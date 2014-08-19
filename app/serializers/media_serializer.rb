class MediaSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :embed
end
