#!/bin/env ruby
# encoding: utf-8
require 'basemodel.rb'
class Menumasuta < BaseModel
  def initialize(code)
    @担当グループコード = code
    @メニューコード = ""
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
  
  def メニュー名称
    @メニュー名称
  end
  
  def メニュー名称= (value)
    @メニュー名称 = value
  end
  
  def 親メニューコード
    @親メニューコード
  end
  
  def 親メニューコード= (value)
    @親メニューコード = value
  end
  
  def 表示順序
    @表示順序
  end
  
  def 表示順序= (value)
    @表示順序 = value
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
  
  # refrence tables
  def 担当グループ名称
    @担当グループ名称
  end
   
  def 担当グループ名称= (value)
    @担当グループ名称 = value
  end
  
  # other 
  def ListName
      @ListName
    end
  
  def ListName= (value)
    @ListName = value
  end
  
  def puts(hashValue)
    @担当グループコード = hashValue["担当グループコード"];
    @メニューコード = hashValue["メニューコード"]; 
    @メニュー名称 = hashValue["メニュー名称"];
    @親メニューコード = hashValue["親メニューコード"]; 
    @表示順序 = hashValue["表示順序"];
    @更新担当者コード = hashValue["更新担当者コード"];
    @更新プログラム = hashValue["更新プログラム"];
    @更新日時 = hashValue["更新日時"];
    @入力日時 = hashValue["入力日時"];
    @ListName = hashValue["LISTNAME"];
    @担当グループ名称 = hashValue["担当グループ名称"];
  end
end