#!/bin/env ruby
# encoding: utf-8
require 'controllerModel/baseControllermodel.rb'
require 'controllerModel/pw_sosiki_syubetuItem.rb'
require 'controllerModel/pw_sosikiItem.rb'

class Pw_SosikicontrollerModel < BasecontrollerModel
  @connection = nil;
  
  def self.selectForm(sosikimeisyo,searchoption,kobasosiki,sosikisyubetu,jigyoki)
       
    @connection = Connection.new();
    query = "SELECT  a.組織コード"
    query +="       , a.組織名称"
    query +="       , a.組織種別コード"
    query +="       , b.組織種別名称"
    query +="       , a.親組織コード"
    query +="       , c.組織名称    AS  親組織名称"
    query +="   FROM 組織マスタ a"
    query +="   , 組織種別マスタ  b"
    query +="   , 組織マスタ c"
    query +="   WHERE  a.組織種別コード  = b.組織種別コード(+) "
    query +="   AND a.事業年月      = c.事業年月(+)"
    query +="   AND a.親組織コード    = c.組織コード(+)"
    
    where = " AND 1=1"
    if !sosikimeisyo.blank? then     
       #F曖昧変換
       searchtext_temp = ActiveRecord::Base.sanitize(sosikimeisyo)
       searchtext_temp = Publicfunction.pf_aimai_henkan(searchtext_temp)
       case searchoption
         when "1" #1:部分一致
           where += " AND regexp_like(a.組織名称, '" + searchtext_temp + "')"
         when "2" #2:前方一致
           where += " AND regexp_like(a.組織名称, '^" + searchtext_temp + "')"
         when "3" #3:後方一致
           where += " AND regexp_like(a.組織名称, '" + searchtext_temp + "$')"
       end
      Rails.logger.info 'searchtext_temp:'+where
     end
    
    if !kobasosiki.blank? then
        where += " AND a.工場組織区分 = #{ActiveRecord::Base.sanitize(kobasosiki)}"
    end
        
    if !sosikisyubetu.blank? then
       where += " AND a.組織種別コード = #{ActiveRecord::Base.sanitize(sosikisyubetu)}"
    end
    
    if !jigyoki.blank? then
       @ldt_date   = Date.parse(jigyoki)
       where += " AND a.事業年月 >= " + ActiveRecord::Base.sanitize(@ldt_date)
       where += " AND a.事業年月 <= " + ActiveRecord::Base.sanitize(@ldt_date)
    end
    
    query += where
    Rails.logger.info 'Pw_SosikicontrollerModel.selectForm:'+query
    @arrSELECT = Array.new;    
    @hashSELECT = Hash.new;
    @hashSELECT = @connection.ExecuteSelectQuery(query);
    index = 0;
    @hashSELECT.each do |hashValue|
       record = PwSosikiItem.new("");
       record.puts(hashValue);
       @arrSELECT[index] = record;
       index = index + 1;
    end
     
     return @arrSELECT;
  end
  
  def self.getSosikiSyubetuList
     @connection = Connection.new();
     #組織種別マスタ
     query = "SELECT  組織種別コード"
     query +="       , 組織種別コード || ' : ' || 組織種別名称 AS 組織種別名称"
     query +="       , 更新担当者コード"
     query +="       ,  更新プログラム"
     query +="       , 更新日時"
     query +="       , 入力日時"
     query +="       , 組織階層区分"
     query +="       , 上位本部組織種別コード"
     query +="   FROM 組織種別マスタ";
     arrSYUBETU = Array.new;    
     hashSYUBETU = Hash.new;
     hashSYUBETU = @connection.ExecuteSelectQuery(query);
     index = 0;
     hashSYUBETU.each do |hashValue|
       record = PwSosikiSyubetuItem.new("");
       record.puts(hashValue);
       arrSYUBETU[index] = record;
       index = index + 1;
     end
     
     return arrSYUBETU    
  end
  
  def self.getSosikiName(sosikiCode)
     @connection = Connection.new();
     #組織マスタ
     query = "SELECT  組織名称"
     query +="   FROM 組織マスタ"
     query +="   WHERE  組織コード  = '"+ sosikiCode +"'"
     
     returnvalue=@connection.ExecuteSelectQueryOne(query) 
     return Publicfunction.pf_nvl_string(returnvalue["組織名称"],"");  
  end
  
def self.pf_ddw_jigyo_nengetu(jigyo_nengetu)
     @connection = Connection.new();
     #組織マスタ
     query = "SELECT  期名称"
     query +="   FROM 事業年月マスタ"
     query +="   WHERE  事業年月  = '#{jigyo_nengetu}'"
     
     returnvalue=@connection.ExecuteSelectQueryOne(query) 
     return Publicfunction.pf_nvl_string(returnvalue["期名称"],"");  
  end
  
end