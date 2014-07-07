module ApplicationHelper
  def title(value)
    unless value.nil?
      @title = "#{value} | ServiceEntrance"      
    end
  end
end
