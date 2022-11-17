#!/bin/env ruby
# encoding: utf-8
class MB_001Item
  def initialize(code)
    @担当者コード = code
  end
  
  def 担当者コード
      @担当者コード
    end
  
  def 担当者コード= (value)
    @担当者コード = value
  end
  
  def 担当者名称
    @担当者名称
  end
   
  def 担当者名称= (value)
    @担当者名称 = value
  end
  
  def 開始日
    @開始日
  end
   
  def 開始日= (value)
    @開始日 = value
  end

  def 終了日
    @終了日
  end
   
  def 終了日= (value)
    @終了日 = value
  end

  def パスワード
    @パスワード
  end
   
  def パスワード= (value)
    @パスワード = value
  end
  
  def パスワード更新日
    @パスワード更新日
  end
   
  def パスワード更新日= (value)
    @パスワード更新日 = value
  end

  def 組織コード
    @組織コード
  end
   
  def 組織コード= (value)
    @組織コード = value
  end
  
  def 担当グループコード
    @担当グループコード
  end
   
  def 担当グループコード= (value)
    @担当グループコード = value
  end

  def ログインユーザー
    @ログインユーザー
  end
   
  def ログインユーザー= (value)
    @ログインユーザー = value
  end
  
  def フォーカス_メニューコード
    @フォーカス_メニューコード
  end
   
  def フォーカス_メニューコード= (value)
    @フォーカス_メニューコード = value
  end
  
  def 社員区分
    @社員区分
  end
   
  def 社員区分= (value)
    @社員区分 = value
  end
  # common
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
  
  def 事業年月
    @事業年月
  end
     
  def 事業年月= (value)
    @事業年月 = value
  end
  
  #reference table
  def 組織名称
    @組織名称
  end
   
  def 組織名称= (value)
    @組織名称 = value
  end
  
  def 担当グループ名称
    @担当グループ名称
  end
   
  def 担当グループ名称= (value)
    @担当グループ名称 = value
  end
  
  def メニュー名称
    @メニュー名称
  end
   
  def メニュー名称= (value)
    @メニュー名称 = value
  end
  
  def puts(hashValue)
    @担当者コード = hashValue["担当者コード"].strip;
    @担当者名称 = hashValue["担当者名称"].strip;
    @開始日 = hashValue["開始日"];
    @終了日 = hashValue["終了日"]; 
    @パスワード = hashValue["パスワード"].strip;
    @パスワード更新日 = hashValue["パスワード更新日"];
    @組織コード = hashValue["組織コード"];
    @担当グループコード = hashValue["担当グループコード"]; 
    @ログインユーザー = hashValue["ログインユーザー"];
    @フォーカス_メニューコード = hashValue["フォーカス＿メニューコード"];
    @社員区分 = hashValue["社員区分"];  
    @更新担当者コード = hashValue["更新担当者コード"];
    @更新プログラム = hashValue["更新プログラム"];
    @更新日時 = hashValue["更新日時"];
    @入力日時 = hashValue["入力日時"];
    @事業年月 = hashValue["事業年月"];
    #refernce table
    @組織名称 = hashValue["組織名称"];
    @担当グループ名称 = hashValue["担当グループ名称"];
    @メニュー名称 = hashValue["メニュー名称"];
  end
end