#!/bin/env ruby
# encoding: utf-8
require 'basemodel.rb'
class Tantogroupbetugamenmasuta < BaseModel
  # 担当グループ別画面マスタ
  def initialize(code)
    @担当グループコード = code
  end
  
  def 担当グループコード
      @担当グループコード
    end
  
  def 担当グループコード= (value)
    @担当グループコード = value
  end

  def メニューコード
      @メニューコード
    end
  
  def メニューコード= (value)
    @メニューコード = value
  end 
   
  def 画面プログラム
      @画面プログラム
    end
  
  def 画面プログラム= (value)
    @画面プログラム = value
  end
   
  def 権限区分
      @権限区分
    end
  
  def 権限区分= (value)
    @権限区分 = value
  end
  
  def 表示順序
      @表示順序
    end
  
  def 表示順序= (value)
    @表示順序 = value
  end
  
  def ボタン名称
      @ボタン名称
    end
  
  def ボタン名称= (value)
    @ボタン名称 = value
  end
  
  def 更新担当者コード
    @更新担当者コード
  end
   
  def 更新担当者コード= (value)
    @更新担当者コード = value
  end
  
  def 更新プログラム
    @更新プログラム
  end
   
  def 更新プログラム= (value)
    @更新プログラム = value
  end
  
  def 更新日時
    @更新日時
  end
   
  def 更新日時= (value)
    @更新日時 = value
  end
  
  def 入力日時
    @入力日時
  end
   
  def 入力日時= (value)
    @入力日時 = value
  end
  
  #from references table
  
  def 担当グループ名称
      @担当グループ名称
    end
  
  def 担当グループ名称= (value)
    @担当グループ名称 = value
  end
  
  def 画面名称
      @画面名称
    end
  
  def 画面名称= (value)
    @画面名称 = value
  end
  
  def メニュー名称
      @メニュー名称
    end
  
  def メニュー名称= (value)
    @メニュー名称 = value
  end
  
  # select list references
  def ListName
      @ListName
    end
  
  def ListName= (value)
    @ListName = value
  end
  
  def puts(hashValue)
    @担当グループコード = hashValue["担当グループコード"];
    @メニューコード = hashValue["メニューコード"];
    @画面プログラム = hashValue["画面プログラム"];
    @権限区分 = hashValue["権限区分"]; 
    @表示順序 = hashValue["表示順序"];
    @ボタン名称 = hashValue["ボタン名称"];
    @更新担当者コード = hashValue["更新担当者コード"];
    @更新プログラム = hashValue["更新プログラム"];
    @更新日時 = hashValue["更新日時"];
    @入力日時 = hashValue["入力日時"];
    @ListName = hashValue["LISTNAME"];
    @担当グループ名称 = hashValue["担当グループ名称"];
    @画面名称 = hashValue["画面名称"];
    @メニュー名称 = hashValue["メニュー名称"];
  end
  
  def self.Get権限区分(index)
    case index
          when "0"
            return "0:使用不可"
          when "1"
            return "1:フル権限"
          when "2"
            return "2:参照のみ"
        else
            return " "
        end
  end
end