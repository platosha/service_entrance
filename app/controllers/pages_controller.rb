class PagesController < ApplicationController
  before_action :authenticate_user!, only: [
    :inside
  ]

  def home
    @exhibits_json ||= ActiveModel::ArraySerializer.new(Exhibit.all,
      each_serializer: ExhibitSerializer
    ).to_json
    @notes_json ||= ActiveModel::ArraySerializer.new(Note.all,
      each_serializer: NoteSerializer
    ).to_json
    @medias_json ||= ActiveModel::ArraySerializer.new(Media.all,
      each_serializer: MediaSerializer
    ).to_json
  end

  def inside
  end

end
