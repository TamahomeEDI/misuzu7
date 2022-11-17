class BaseModel
  def message
    @message
  end
  
  def message= (msg)
    @message = msg
  end
  # createモード, editモード　：　フォームのactionに指定します。
  def action_name
    @action_name
  end
  
  def action_name= (action)
    @action_name = action
  end
end