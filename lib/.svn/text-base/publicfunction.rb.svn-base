#!/bin/env ruby
# encoding: utf-8

class Publicfunction
  #================================================================
  #   名　称    Publicfunction
  #   説　明    common function
  #   補　足
  #   引　数 なし
  #   戻　値
  # (history)
  #   date         ver        name          comments
  #  -------     -----      ----------  -----------------
  #  2012.09.14  1.00.00     dvquan       fun
  #  2012.09.08  1.00.00     dvquan       新規作成
  #=================================================================
@connection=nil
  
  #Rails.logger.info ""
  # const
  def self.MODE_BEFORE
    return 0
  end

  def self.MODE_AFFTER
    return 1
  end
  #const
  def self.pf_nvl_string(str, replace)
    stringRet = str
    if stringRet.nil? then
      stringRet = ""
    else
      stringRet = str.strip
    end
    
    if stringRet == "" then
      stringRet = replace
    end
    
    return stringRet
  end
  
  def self.pf_nvl_number(num, replace)
    numRet = num
    if numRet.nil? then
      numRet = replace
    end
    
    return numRet
  end
  
  def self.pf_aimai_henkan(str)
    replaceString = Array.new
    replaceString  = ["~", "'", "%"]
    return self.pf_replace_ex(str, replaceString, "")
  end
  
  def self.pf_replace_ex(str, arrReplace, withString)
    index = 0
    retString = str
    while index < arrReplace.size
      retString = self.pf_replace(retString, arrReplace[index], withString)
      index = index + 1
    end
    
    # using procedure to replace string amai
    connection = Connection.new();
    retString = connection.GetAmaiHenkan(retString)
    return retString
  end
  
  def self.pf_replace(str, strReplace, withString)
    # replace withString by strReplace in str
    index = 0
    retString = ""
    while index < str.length
      if str[index] != strReplace then
        retString += str[index]
      end
      
      index = index + 1
    end
    
    return retString
  end
  
  def self.pf_csv_cut(csvString)
    # csvString = 1,2,3,4,5,6
    index = 0
    retArr = Array.new
    markSign = ','
    retIndex = 0;
    tempString = ""
    # add mark end
    csvString = Publicfunction.pf_nvl_string(csvString, "") + ","
    while index < csvString.length
      if csvString[index] == markSign then
        retArr[retIndex] = tempString
        Rails.logger.info "pf_csv_cut.New key: " + tempString
        tempString = ""
        retIndex = retIndex + 1
      else
        tempString = tempString + csvString[index]
      end

      index = index + 1
    end
    
    return retArr;
  end
  
  def self.pf_fillchar(str, charReplace, length, direct)
    # direct = 0 replace before. 前のｓｔｒ
    # direct = 1 replace affter.　後のｓｔｒ
    # fill strreplace to str if str.length < length
    temp = pf_nvl_string(str, "")
    while temp.length < length do
      if direct == Publicfunction.MODE_BEFORE then
        temp = charReplace + temp;
      else
        temp = temp + charReplace;
      end
    end
    
    return temp
  end
  
  def self.pf_Format_Date(dateval, formatstring)
    # return string
    # formatstring : "%Y/%m/%d" "%Y-%m-%d %H:%M:%S"
    if dateval.nil? then
      return ""
    end
        
    begin
      stringFormat = dateval.strftime(formatstring)
    rescue
       #do something if invalid
      stringFormat = ""
    end
  
    return stringFormat
  end

  #------------------------------------  DATA BASE FUNCTION ---------------------------------------
  def self.pf_get_tanto_single(conn, tantocode, date)
    # kaishidate = GetTantoBeginDate
    # conn = connection
    #Tantogroupmasuta
    query = "SELECT  担当者コード"
    query +="       , 担当者名称"
    query +="       , 開始日"
    query +="       , 終了日"
    query +="       , パスワード"
    query +="       , パスワード更新日"
    query +="       , 組織コード"
    query +="       , 担当グループコード"
    query +="       , ログインユーザー"
    query +="       , フォーカス＿メニューコード"
    query +="       , 社員区分"  
    query +="       , 更新担当者コード"
    query +="      , 更新プログラム"
    query +="      , 更新日時"
    query +="      , 入力日時 "
    query +="   FROM 担当者マスタ";
    query +="   WHERE 担当者コード='" + tantocode + "'";
    query +="   AND 開始日= F担当者＿開始日取得('" + tantocode + "', " + ActiveRecord::Base.sanitize(date) + ")";

    tantorec = conn.ExecuteSelectQueryOne(query)
    return tantorec
  end
  
  def self.pf_GetHonjitu()
    # 担当者の開始日を取得する。
    # connection = Connection object
    # return date
    @connection=Connection.new();
    conn = @connection.CreateConnect();
    query = "SELECT F本日日付取得 AS HONJUTUDATE FROM DUAL";
    cursor = conn.parse(query);
    cursor.exec    
    if r = cursor.fetch_hash()
      tantoDate = r["HONJUTUDATE"];
    end
    
    cursor.close();
    conn.logoff; 
    return tantoDate;
  end
  
  def self.pf_GetJigyoDate(kijunDate)
    # 事業年月を取得する。
    # connection = Connection object
    # return date
    @connection=Connection.new();
    conn = @connection.CreateConnect();
    query = "SELECT F事業年月取得(" + ActiveRecord::Base.sanitize(kijunDate) + ") AS JIGYODATE FROM DUAL";
    cursor = conn.parse(query);
    cursor.exec    
    if r = cursor.fetch_hash()
      datevalue = r["JIGYODATE"];
    end
    
    cursor.close();
    conn.logoff; 
    return datevalue;
  end
  
  def self.pf_GetTantoGroupList(connection)
    # connection = Connection.new();
    #using for select list refences
    # connection = Connection.new();
    #Tantogroupmasuta
    query = "SELECT  担当グループコード"
    query +="       , 担当グループコード || ' : ' || 担当グループ名称 AS LISTNAME"
    query +="       , 担当グループ名称"
    query +="       , 更新担当者コード"
    query +="      , 更新プログラム"
    query +="      , 更新日時"
    query +="      , 入力日時 "
    query +="   FROM 担当グループマスタ";
    # sort
    query +=" ORDER BY 担当グループコード"; 
    models = Array.new;    
    models1 = Hash.new;
    models1 = connection.ExecuteSelectQuery(query);
    index = 0;
    models1.each do |hashValue|
      record = Tantogroupmasuta.new("");
      record.puts(hashValue);
      models[index] = record;
      index = index + 1;
    end
    
    return models
  end
  
  def self.pf_GetTantoGroupOne(connection, tantogroupcode)
    # connection = Connection.new();
    #using for select list refences
    # connection = Connection.new();
    where = ""
    if Publicfunction.pf_nvl_string(tantogroupcode, "") != "" then
      where = " WHERE 担当グループコード = '" + tantogroupcode + "'"
    end
    #Tantogroupmasuta
    query = "SELECT  担当グループコード"
    query +="       , 担当グループ名称"
    query +="       , 更新担当者コード"
    query +="      , 更新プログラム"
    query +="      , 更新日時"
    query +="      , 入力日時 "
    query +="   FROM 担当グループマスタ";
    #add where
    query += where
    # sort
    query +=" ORDER BY 担当グループコード";   
    models1 = Hash.new;
    models1 = connection.ExecuteSelectQuery(query);

    record = Tantogroupmasuta.new("");
    models1.each do |hashValue|
      record = Tantogroupmasuta.new("");
      record.puts(hashValue);
    end
    
    return record
  end

  def self.pf_GetMenumasutaOne(connection, tantogroupcode, menucode)
    #**** get data for menumasuta
    selectQuery = "SELECT a.担当グループコード"
    selectQuery += ", a.メニューコード"
    selectQuery += ", a.メニュー名称"
    selectQuery += ", a.親メニューコード"
    selectQuery += ", a.表示順序"
    selectQuery += ", a.更新担当者コード"
    selectQuery += ", a.更新プログラム"
    selectQuery += ", a.更新日時"
    selectQuery += ", a.入力日時"
    selectQuery += " FROM  メニューマスタ a "
    selectQuery += " WHERE a.担当グループコード  = '" + tantogroupcode + "'"
    # select with menu is child of root.
    selectQuery += " AND  a.メニューコード = '" + menucode + "'"
    
    models1 = Hash.new;
    record = Menumasuta.new("");
    models1 = connection.ExecuteSelectQuery(selectQuery);
    models1.each do |hashValue|
      record = Menumasuta.new("");
      record.puts(hashValue);
    end
    
    return record
  end
  
  def self.pf_GetMenuMasutaCode(connection)
    #メニューコードを取得する。
    conn = connection.CreateConnect();
    query = "SELECT メニュー連番.nextval AS MENUCODE FROM DUAL"
    cursor = conn.parse(query);
    cursor.exec
    menuId = 0;    
    if r = cursor.fetch_hash()
      menuId = r["MENUCODE"];
    end
    
    if !menuId.nil? then
      menuId = menuId.truncate
      menuId = pf_fillchar(menuId.to_s, "0", 4, Publicfunction.MODE_BEFORE)
    else
      menuId = "0000"
    end
    
    cursor.close();
    conn.logoff; 
    return menuId;
  end
  
def self.pf_format_cut(csvString,format)
    # csvString = 1,2,3,4,5,6 or 1;2;3;4......
    index = 0
    retArr = Array.new
    markSign = format
    retIndex = 0;
    tempString = ""
    # add mark end
    csvString = Publicfunction.pf_nvl_string(csvString, "") + format
    while index < csvString.length
      if csvString[index] == markSign then
        retArr[retIndex] = tempString
        Rails.logger.info "pf_format_cut.New key: " + tempString
        tempString = ""
        retIndex = retIndex + 1
      else
        tempString = tempString + csvString[index]
      end

      index = index + 1
    end
    
    return retArr;
  end
  
def self.pf_get_initial_str(as_prog,as_dataobject,as_column)
    #メニューコードを取得する。
    connection = Connection.new();
    conn = connection.CreateConnect();
    query = "SELECT F初期値文字取得('"+ as_prog +"', '"+ as_dataobject +"', '"+ as_column +"') AS パスワード from dual"
    Rails.logger.info "pf_get_initial_str: " + query
    cursor = conn.parse(query);
    cursor.exec
    returnvalue = 0;    
    if r = cursor.fetch_hash()
      returnvalue = r["パスワード"];
    end
    
    returnvalue=pf_nvl_string(returnvalue, "")
    
    cursor.close();
    conn.logoff; 
    return returnvalue;
  end
end