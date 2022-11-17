#!/bin/env ruby
# encoding: utf-8
class MB_001headItem
  def initialize(tantogroupcode,sosikicode,sosikiname,tantocode,searchtext,seachoption,kijundate,jigyodate)
    @担当グループコード = tantogroupcode
    @組織コード = sosikicode
    @組織名称 = sosikiname
    @担当者コード = tantocode
    @担当者名称曖昧 = searchtext
    @担当者名称曖昧区分 = seachoption
    @基準日 = kijundate
    @事業年月 = jigyodate
  end
  
  def 担当グループコード
    @担当グループコード
  end
   
  def 担当グループコード= (value)
    @担当グループコード = value
  end
  
  def 組織コード
      @組織コード
  end
   
  def 組織コード= (value)
    @組織コード = value
  end
  
  def 組織名称
      @組織名称
  end
   
  def 組織名称= (value)
    @組織名称 = value
  end
  
  def 事業年月
      @事業年月
  end
     
  def 事業年月= (value)
    @事業年月 = value
  end
  
  def 担当者コード
    @担当者コード
  end
  
  def 担当者コード= (value)
    @担当者コード = value
  end
  
  def 担当者名称曖昧
    @担当者名称曖昧
  end
  
  def 担当者名称曖昧= (value)
    @担当者名称曖昧 = value
  end
  
  def 担当者名称曖昧区分
      @担当者名称曖昧区分
  end
  
  def 担当者名称曖昧区分= (value)
    @担当者名称曖昧区分 = value
  end
  
  def 基準日
     @基準日
  end
  
  def 基準日= (value)
    @基準日 = value
  end
 
end