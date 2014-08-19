class Media < ActiveRecord::Base
  paginates_per 100

  validates :embed,
            presence: true

  def self.search_and_order(search, page_number)
    if search
      where("name LIKE ?", "%#{search.downcase}%").page page_number
    else
      page(page_number)
    end
  end
end
