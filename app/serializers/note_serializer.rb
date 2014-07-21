class NoteSerializer < ActiveModel::Serializer
  attributes :id,
             :body,
             :author
end
