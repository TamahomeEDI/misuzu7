#!/bin/env ruby
# encoding: utf-8
require 'controllerModel/baseControllermodel.rb'
require 'tantogroupmasuta_model.rb'
require 'menumasuta_model.rb'
require 'sosikimasuta_model.rb'
require 'tantosyamasuta_model.rb'
require 'controllerModel/mb_001Item.rb'

class M135controllerModel < BasecontrollerModel
  @connection = nil;
  

     
  def self.findAll()
    @connection = Connection.new();
    # execute query for update, delete, insert    
    models = Hash.new;
    query = "SELECT  生産管轄工場コード"
    query +="       , 生産管轄工場名称"
    query +="       , 自社外注区分"
    query +="      , 更新担当者コード"
    query +="       , 更新プログラム"
    query +="      , 更新日時"
    query +="      , 入力日時 "
    query +="   FROM 生産管轄工場マスタ";
    # sort
    query +=" ORDER BY 生産管轄工場コード"; 
    models = @connection.ExecuteSelectQuery(query);    
    return models;
  end  
 
  
  def self.updateForm(arrDeletes,arrUpdates,arrAddnews)
        @connection = Connection.new();
        # execute query for update, delete, insert
        conn = @connection.CreateConnect();
        results = "0"
        begin
          @SEISANCODE=nil#担当者コード
          @SEISANMEISYOU=nil#担当者名称
          @JISHASOTOKUBUN=nil#開始日

          @KOUSINTANTOUSYACODE=nil#更新担当者コード  
          @GETPROGID=nil#更新プログラム 
          sysdate = @connection.GetSystemDate;
          sysdateString = "TO_DATE('" + sysdate + "','YYYY/MM/DD HH24:MI:SS')";

          
          #Insert table
          insertQuery = "INSERT INTO 生産管轄工場マスタ(生産管轄工場コード, 生産管轄工場名称, 自社外注区分, 更新担当者コード, 更新プログラム, 更新日時, 入力日時)"
          insertQuery += "VALUES(:SEISANCODE,:SEISANMEISYOU,:JISHASOTOKUBUN,:KOUSINTANTOUSYACODE,:GETPROGID,"+ sysdateString +","+ sysdateString +")" 
          arrAddnews.each do |arrAddnew|
            @SEISANCODE=arrAddnew[0]#担当者コード
            @SEISANMEISYOU=arrAddnew[1]#担当者名称
            @JISHASOTOKUBUN=arrAddnew[2]#開始日
            @KOUSINTANTOUSYACODE=arrAddnew[3]#更新担当者コード  
            @GETPROGID=arrAddnew[4]#更新プログラム 
            Rails.logger.info 'AddnewExecute: ' + @SEISANCODE+ "," +@SEISANMEISYOU+ "," +@JISHASOTOKUBUN+ "," +@KOUSINTANTOUSYACODE+ "," +@GETPROGID
            
            cursor = conn.parse(insertQuery);
            # bind by position
            cursor.bind_param(':SEISANCODE', @SEISANCODE)
            cursor.bind_param(':SEISANMEISYOU', @SEISANMEISYOU) 
            cursor.bind_param(':JISHASOTOKUBUN', @JISHASOTOKUBUN)  
            cursor.bind_param(':KOUSINTANTOUSYACODE', @KOUSINTANTOUSYACODE) 
            cursor.bind_param(':GETPROGID', @GETPROGID) 
            cursor.exec
            cursor.close();
          end
          
          #Update table
          updateQuery = "UPDATE 生産管轄工場マスタ "
          updateQuery += " SET 生産管轄工場名称 = :SEISANMEISYOU";
          updateQuery += ", 自社外注区分 = :JISHASOTOKUBUN";
          updateQuery += ", 更新担当者コード = :KOUSINTANTOUSYACODE";
          updateQuery += ", 更新日時 = " + sysdateString; 
          updateQuery += " WHERE 生産管轄工場マスタ .生産管轄工場コード = :SEISANCODE";  
               
          arrUpdates.each do |arrUpdate|
            @SEISANCODE=arrUpdate[0]
            @SEISANMEISYOU=arrUpdate[1]
            @JISHASOTOKUBUN=arrUpdate[2]
            @KOUSINTANTOUSYACODE=arrUpdate[3] 
            Rails.logger.info 'UpdateExecute: ' + @SEISANCODE+ "," +@SEISANMEISYOU+ "," +@JISHASOTOKUBUN+ "," +@KOUSINTANTOUSYACODE
            
            cursor = conn.parse(updateQuery);
            # bind by position
            cursor.bind_param(':SEISANCODE', @SEISANCODE)
            cursor.bind_param(':SEISANMEISYOU', @SEISANMEISYOU) 
            cursor.bind_param(':JISHASOTOKUBUN', @JISHASOTOKUBUN) 
            cursor.bind_param(':KOUSINTANTOUSYACODE', @KOUSINTANTOUSYACODE) 
            cursor.exec
            cursor.close();
          end
          
          #Delete table
          deleteQuery = "DELETE FROM 生産管轄工場マスタ"
          deleteQuery += " WHERE 生産管轄工場コード = :SEISANCODE";

          arrDeletes.each do |arrDelete|
            @SEISANCODE=arrDelete[0]#担当者コード
           
            Rails.logger.info 'DeleteExecute: ' + @SEISANCODE
            
            cursor = conn.parse(deleteQuery);
            # bind by position
            cursor.bind_param(':SEISANCODE', @SEISANCODE)
            cursor.exec
            cursor.close();
          end
          
          results = "0";
        rescue => error
          conn.rollback();
          results = "1";
          Rails.logger.info 'ExecuteQuery.ERROR: ' + error.to_s()
        ensure
          conn.commit();
          conn.logoff;
        end
      
        return results;
  end
  
end