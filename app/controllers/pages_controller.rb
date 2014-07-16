class PagesController < ApplicationController
  before_action :authenticate_user!, only: [
    :inside
  ]

  def home
    @exhibits_json ||= ActiveModel::ArraySerializer.new(Exhibit.all,
      each_serializer: ExhibitSerializer
    ).to_json
  end

  def inside
  end

end
