module ApplicationHelper
  def title(value)
    unless value.nil?
      @title = "#{value} | Service Entrance"
    end
  end
end
