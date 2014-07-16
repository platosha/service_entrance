class Exhibit < ActiveRecord::Base
  mount_uploader :image, ImageUploader

  paginates_per 100

  SUBTYPES = %w(
    object
    painting
    sculpture
  )

  validates :subtype,
    inclusion: { in: SUBTYPES,
                 message: "%{value} is not a valid subtype" }

  validates :name,
            :author,
            :year,
            :materials,
            :size,
            :owner,
            :image,
            presence: true

  def self.search_and_order(search, page_number)
    if search
      where("name LIKE ?", "%#{search.downcase}%").page page_number
    else
      page(page_number)
    end
  end
end
