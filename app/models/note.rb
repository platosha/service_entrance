class Note < ActiveRecord::Base
  paginates_per 100

  validates :body,
            :author,
            presence: true

  def self.search_and_order(search, page_number)
    if search
      where("body LIKE ?", "%#{search.downcase}%").page page_number
    else
      page(page_number)
    end
  end
end
