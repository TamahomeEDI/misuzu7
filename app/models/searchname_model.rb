#!/bin/env ruby
# encoding: utf-8
class SearchName
  def self.GetSearchOption(index)
    # 画面名称曖昧
    case index
          when "1"
            return "1:部分一致"
          when "2"
            return "2:前方一致"
          when "3"
            return "3:後方一致"
        else
            return " "
        end
  end
end
