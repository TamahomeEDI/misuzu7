#!/bin/env ruby
# encoding: utf-8
require 'basemodel.rb'
require 'csv' # csvファイルを出力。
require 'iconv'
class Seisankankatukoujoumasuta < BaseModel
  def initialize(code)
    @生産管轄工場コード = code
  end

  def 生産管轄工場コード
    @生産管轄工場コード
  end
  
  def 生産管轄工場コード= (kojocode)
    @生産管轄工場コード = kojocode
  end
  
  def 生産管轄工場名称
    @生産管轄工場名称
  end
  
  def 生産管轄工場名称= (kojoname)
    @生産管轄工場名称 = kojoname
  end
  
  def 自社外注区分
    @自社外注区分
  end
  
  def 自社外注区分= (kubun)
    @自社外注区分 = kubun
  end
  
  def 更新担当者コード
    @更新担当者コード
  end
  
  def 更新担当者コード= (tantoCode)
    @更新担当者コード = tantoCode
  end
  
  def 更新プログラム
    @更新プログラム
  end
  
  def 更新プログラム= (program)
    @更新プログラム = program
  end
  
  def 更新日時
    @更新日時
  end
  
  def 更新日時= (updatedDate)
    @更新日時 = updatedDate
  end
  
  def 入力日時
    @入力日時
  end
  
  def 入力日時= (insertDate)
    @入力日時 = insertDate
  end
  
  def puts(hashValue)
    @生産管轄工場コード = hashValue["生産管轄工場コード"];
    @生産管轄工場名称 = hashValue["生産管轄工場名称"]; 
    @自社外注区分 = hashValue["自社外注区分"];
    @更新担当者コード = hashValue["更新担当者コード"];
    @更新プログラム = hashValue["更新プログラム"];
    @更新日時 = hashValue["更新日時"];
    @入力日時 = hashValue["入力日時"];
  end
  
  def self.Get自社外注区分名称(index)
    case index
          when "1"
            return "1:自社"
          when "2"
            return "2:外注"
          when "3"
            return "3:仕入"
        else
            return " "
        end
  end
  
  def self.index(connection)
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
    models = connection.ExecuteSelectQuery(query);
    return models;
  end
  
  def self.create(connection, mode, model)
    sysdate = connection.GetSystemDate;
    sysdateString = "TO_DATE('" + sysdate + "','YYYY/MM/DD HH24:MI:SS')";
    
    insertQuery = "INSERT INTO 生産管轄工場マスタ(生産管轄工場コード, 生産管轄工場名称, 自社外注区分, 更新担当者コード, 更新プログラム, 更新日時, 入力日時)"
    insertQuery += "VALUES( ";
    insertQuery += " " + ActiveRecord::Base.sanitize(model.生産管轄工場コード) + "";
    insertQuery += ", " + ActiveRecord::Base.sanitize(model.生産管轄工場名称) + "";
    insertQuery += ", '" + model.自社外注区分 + "'";
    insertQuery += ", '" + model.更新担当者コード + "'";
    insertQuery += ", '" + model.更新プログラム + "'";
    insertQuery += ", " + sysdateString;
    insertQuery += ", " + sysdateString;    
    insertQuery += " )";
    
    if mode == "1" then
      insertQuery = "INSERT INTO 生産管轄工場マスタ(生産管轄工場コード, 生産管轄工場名称, 自社外注区分, 更新担当者コード, 更新プログラム, 更新日時, 入力日時)"
      insertQuery += "VALUES( ";
      insertQuery += " " + ActiveRecord::Base.sanitize(model.生産管轄工場コード) + "";
      insertQuery += ", " + ActiveRecord::Base.sanitize(model.生産管轄工場名称) + "";
      insertQuery += ", '" + model.自社外注区分 + "'";
      insertQuery += ", '" + model.更新担当者コード + "'";
      insertQuery += ", '" + model.更新プログラム + "'";
      insertQuery += ", " + sysdateString;
      insertQuery += ", " + sysdateString;    
      insertQuery += " )";
    end 
    result = connection.ExecuteQuery(insertQuery);
    return result;
  end
  
  def self.insert(connection, id)
    query = "SELECT  生産管轄工場コード"
    query +="       , 生産管轄工場名称"
    query +="       , 自社外注区分"
    query +="      , 更新担当者コード"
    query +="       , 更新プログラム"
    query +="      , 更新日時"
    query +="      , 入力日時 "
    query +="   FROM 生産管轄工場マスタ";
    query +="   WHERE 生産管轄工場コード='" + id + "'";
    
    records = connection.ExecuteSelectQuery(query)
    return records;
  end
  
  def self.edit(connection, id)
    
    query = "SELECT  生産管轄工場コード"
    query +="       , 生産管轄工場名称"
    query +="       , 自社外注区分"
    query +="      , 更新担当者コード"
    query +="       , 更新プログラム"
    query +="      , 更新日時"
    query +="      , 入力日時 "
    query +="   FROM 生産管轄工場マスタ";
    query +="   WHERE 生産管轄工場コード='" + id + "'";
    
    records = connection.ExecuteSelectQuery(query)
    return records;
  end
  
  def self.update(connection, id, param, tantoCode)
    #生産管轄工場マスタを変換します。
    records = Seisankankatukoujoumasuta.edit(connection,id); 
    if !records.nil?
      model = Seisankankatukoujoumasuta.new("1");
      model.puts(records[0]);
      sysdate = connection.GetSystemDate;
     
      sysdateString = "TO_DATE('" + sysdate + "','YYYY/MM/DD HH24:MI:SS')";
      
      
     
      if tantoCode.nil?
        tantoCode = " "
      end
      model.生産管轄工場名称 = param[:生産管轄工場名称];
      model.自社外注区分 = param[:自社外注区分];   
      updateQuery = "UPDATE 生産管轄工場マスタ "
      updateQuery += " SET 生産管轄工場名称 = " + ActiveRecord::Base.sanitize(model.生産管轄工場名称) + "";
      updateQuery += ", 自社外注区分 = '" + model.自社外注区分 + "'";
      updateQuery += ", 更新担当者コード = '" + tantoCode + "'";
      updateQuery += ", 更新日時 = " + sysdateString; 
      updateQuery += " WHERE 生産管轄工場マスタ .生産管轄工場コード = '" + model.生産管轄工場コード + "'";   
      result = connection.ExecuteQuery(updateQuery);
     
      return result; 
    end
  end
  
  def self.show(connection, id)
    query = "SELECT  生産管轄工場コード"
    query +="       , 生産管轄工場名称"
    query +="       , 自社外注区分"
    query +="      , 更新担当者コード"
    query +="       , 更新プログラム"
    query +="      , 更新日時"
    query +="      , 入力日時 "
    query +="   FROM 生産管轄工場マスタ";
    query +="   WHERE 生産管轄工場コード='" + id + "'";
    
    records = connection.ExecuteSelectQuery(query);
    return records;
  end 
  
  def self.destroy(connection, id)
    deleteQuery = "DELETE FROM 生産管轄工場マスタ"
    deleteQuery += " WHERE 生産管轄工場コード = '" + id + "'";
    result = connection.ExecuteQuery(deleteQuery);  
    if result == "0"
     # if fragment_exist?('seisankankatukoujourisuto', nil) == false
      Seisankankatukoujoumasuta.showAll(connection);
     # end
    end  
    return result;    
  end
  
  def self.showAll(connection)
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
    records = connection.ExecuteSelectQuery(query);
    return records;
  end 
  
  def self.export(connection)
    query = "SELECT  生産管轄工場コード"
    query +="       , 生産管轄工場名称"
    query +="       , 自社外注区分"
    query +="      , 更新担当者コード"
    query +="       , 更新プログラム"
    query +="      , 更新日時"
    query +="      , 入力日時 "
    query +="   FROM 生産管轄工場マスタ ORDER BY 生産管轄工場コード";    
    models = Hash.new;
    models = connection.ExecuteSelectQuery(query);
    return models;
  end
end