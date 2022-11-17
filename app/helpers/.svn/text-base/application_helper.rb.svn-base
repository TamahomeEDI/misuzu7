module ApplicationHelper
  def title(page_title)
    content_for :title, page_title.to_s
  end
  
  def current_url(new_params)
    # i merge curent url with csv format.
    # link to change to <%= link_to "name link", current_url(:format => :csv)%>
    url_for :params => params.merge(new_params)
  end
  
  def getHonjitu()
    @connection = Connection.new();
    @honjitudate = @connection.GetHonjitu()
    
    return @honjitudate
  end

end
