#!/bin/env ruby
# encoding: utf-8
class PwSosikiItem
  def initialize(code)
    @組織コード = code
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
  
  def 組織種別コード
    @組織種別コード
  end
   
  def 組織種別コード= (value)
    @組織種別コード = value
  end

  def 組織種別名称
    @組織種別名称
  end
   
  def 組織種別名称= (value)
    @組織種別名称 = value
  end

  def 親組織コード
    @親組織コード
  end
   
  def 親組織コード= (value)
    @親組織コード = value
  end
  
  def 親組織名称
    @親組織名称
  end
   
  def 親組織名称= (value)
    @親組織名称 = value
  end

  def puts(hashValue)
    @組織コード = hashValue["組織コード"];
    @組織名称 = hashValue["組織名称"];
    @組織種別コード = hashValue["組織種別コード"];
    @組織種別名称 = hashValue["組織種別名称"];
    @親組織コード = hashValue["親組織コード"];
    @親組織名称 = hashValue["親組織名称"];
  end
end