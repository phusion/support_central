module ApplicationHelper
  def page_title
    result = "Support Central"
    if @title
      result = "#{@title} - #{result}"
    end
    result
  end
end
