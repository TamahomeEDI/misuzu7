#!/bin/env ruby
# encoding: utf-8
require 'controllerModel/baseControllermodel.rb'
require 'tantogroupmasuta_model.rb'
require 'menumasuta_model.rb'
require 'sosikimasuta_model.rb'
require 'tantosyamasuta_model.rb'
require 'controllerModel/mb_001mainItem.rb'

class MB_001controllerModel < BasecontrollerModel
  @connection = nil;
  
  def self.selectForm(tantogroupcode,tantocode,sosikicode,searchtext,seachoption,kinjundatestring)
       @connection = Connection.new();
       # 基準日 = honjitu
       @honjitudate = Publicfunction.pf_GetHonjitu()
       Rails.logger.info 'MB_001controllerModel.@honjitudate: ' + @honjitudate.strftime("%Y/%m/%d %H:%M:%S")
       
        query = "SELECT  a.担当者コード"
        query +="       , a.担当者名称"
        query +="       , a.開始日"
        query +="       , a.終了日"
        query +="       , a.パスワード"
        query +="       , a.パスワード更新日"
        query +="       , a.組織コード"
        query +="       , c.組織名称"
        query +="       , a.担当グループコード"
        query +="       , b.担当グループ名称"
        query +="       , a.ログインユーザー"
        query +="       , a.フォーカス＿メニューコード"
        query +="       , d.メニュー名称"
        query +="       , a.社員区分"
        query +="       , a.更新担当者コード"
        query +="      , a.更新プログラム"
        query +="      , a.更新日時"
        query +="      , a.入力日時 "
        query +="       , TO_DATE('" + @honjitudate.strftime("%Y/%m/%d") + "', 'YYYY/MM/DD') AS 事業年月"
        query +="   FROM 担当者マスタ a"
        query +="   , 担当グループマスタ b"
        query +="   , ( SELECT  e.組織コード"
        query +="           ,   e.組織名称"
        query +="           ,   e.事業年月"
        query +="       FROM    組織マスタ e"
        #WHERE    e."事業年月"  = to_date(to_char(:adt_jigyou , 'YYYY/MM/DD'))    
        query +="       WHERE    e.事業年月  = F事業年月取得(to_date(to_char("+ ActiveRecord::Base.sanitize(@honjitudate) + ", 'YYYY/MM/DD')) )"
        query +="     ) c"
        query +="   , メニューマスタ d"
        query +="   WHERE  a.担当グループコード       = b.担当グループコード(+) "
        query +="   AND a.組織コード             = c.組織コード(+)"
        query +="   AND a.担当グループコード       = d.担当グループコード(+)"
        query +="   AND a.フォーカス＿メニューコード = d.メニューコード(+)"
       
       where = " AND 1=1"
       # 3. get search data
       if tantogroupcode != "" then
         where += " AND a.担当グループコード = " + ActiveRecord::Base.sanitize(tantogroupcode)
       end
   
       if sosikicode != "" then
         where += " AND a.組織コード = " + ActiveRecord::Base.sanitize(sosikicode)
       end
           
       if tantocode != "" then
         where += " AND a.担当者コード = " + ActiveRecord::Base.sanitize(tantocode)
       end
   
       if searchtext != "" then     
         #F曖昧変換
         searchtext_temp = ActiveRecord::Base.sanitize(searchtext)
         searchtext_temp = Publicfunction.pf_aimai_henkan(searchtext_temp)
         case seachoption
           when "1" #1:部分一致
             where += " AND regexp_like(a.担当者名称, '" + searchtext_temp + "')"
           when "2" #2:前方一致
             where += " AND regexp_like(a.担当者名称, '^" + searchtext_temp + "')"
           when "3" #3:後方一致
             where += " AND regexp_like(a.担当者名称, '" + searchtext_temp + "$')"
         end
       end
         
       # kijun date
       if kinjundatestring != "" then
         begin
           @kijundate = Date.parse(kinjundatestring)
           where += " AND a.開始日 <= " + ActiveRecord::Base.sanitize(@kijundate)
           where += " AND a.終了日 >= " + ActiveRecord::Base.sanitize(@kijundate)
         rescue
            #do something if invalid
           @kijundate = @honjitudate
         end
   
        Rails.logger.info 'MB_001controllerModel.@kinjundatestring: ' + @kijundate.strftime("%Y/%m/%d")
        else
         @kijundate = @honjitudate
         Rails.logger.info 'MB_001controllerModel.@kinjundatestring: NULL'
       end
     
       query += where
       Rails.logger.info 'MB_001controllerModel.where: ' + where
       # sort
       query +=" ORDER BY a.担当者コード"; 
       
       @arrSELECT = Array.new;    
       @hashSELECT = Hash.new;
       @hashSELECT = @connection.ExecuteSelectQuery(query);
       index = 0;
       @hashSELECT.each do |hashValue|
         record = MB_001mainItem.new("");
         record.puts(hashValue);
         @arrSELECT[index] = record;
         index = index + 1;
       end
       
       return @arrSELECT;
    end
  
  # ------------------------------ Functioｎ ---------------------------------
  def self.getTantoGroupList
    @connection = Connection.new();
    #Tantogroupmasuta
    query = "SELECT  担当グループコード"
    query +="       , 担当グループコード || ' : ' || 担当グループ名称 AS 担当グループ名称"
    query +="       , 更新担当者コード"
    query +="      , 更新プログラム"
    query +="      , 更新日時"
    query +="      , 入力日時 "
    query +="   FROM 担当グループマスタ";
    # sort
    query +=" ORDER BY 担当グループコード"; 
    arrTANTOGROUP = Array.new;    
    hashTANTOGROUP = Hash.new;
    hashTANTOGROUP = @connection.ExecuteSelectQuery(query);
    index = 0;
    hashTANTOGROUP.each do |hashValue|
      record = Tantogroupmasuta.new("");
      record.puts(hashValue);
      arrTANTOGROUP[index] = record;
      index = index + 1;
    end
    
    return arrTANTOGROUP
  end
    
def self.getFocusMenuListWithTantoGroup(groupcode)
    @connection = Connection.new();
    query = "SELECT  担当グループコード"
    query +="       , メニューコード"
    query +="       , メニューコード || ' : ' || メニュー名称 AS LISTNAME"
    query +="       , メニュー名称"
    query +="       , 親メニューコード"
    query +="       , 表示順序"
    query +="       , 更新担当者コード"
    query +="      , 更新プログラム"
    query +="      , 更新日時"
    query +="      , 入力日時 "
    query +="   FROM メニューマスタ";
    # add where
    where = " WHERE 1=1"
    if groupcode.nil? then
      where += " AND 1 = 0"
    else
      where += " AND 担当グループコード = '" + groupcode + "'"
    end
    query += where
    # sort
    query +=" ORDER BY メニュー名称"; 
    arrMenu = Array.new;    
    hashMenu = Hash.new;
    hashMenu = @connection.ExecuteSelectQuery(query);
    
    index = 0;
    hashMenu.each do |hashValue|
      record = Menumasuta.new("");
      record.puts(hashValue);
      arrMenu[index] = record;
      index = index + 1;
    end
    
    return arrMenu 
end
    
def self.getSosikiListWithStringDate(kijundate)
    @connection = Connection.new();
    #Tantogroupmasuta
    query = "SELECT  組織コード"
    query +="       , 組織名称"
    query +="       , 組織コード || ' : ' || 組織名称 AS LISTNAME"
    query +="       , 事業年月"
    query +="       , 組織種別コード"
    query +="       , 工場組織区分"
    query +="       , 親組織コード"
    query +="       , 表示順序"
    query +="       , 管轄組織区分"
    query +="       , 発注組織区分"
    query +="       , 売上組織区分"
    query +="       , 会計部門コード"  
    query +="       , 更新担当者コード"
    query +="      , 更新プログラム"
    query +="      , 更新日時"
    query +="      , 入力日時 "
    query +="   FROM 組織マスタ";
    # add where
    where = " WHERE 1=1"
    if !kijundate.nil? then
      # get jigyodate from kijundate
      jigyoDate = Publicfunction.pf_GetJigyoDate(kijundate)
      # stringDate 
      #事業年月 >= stringDate && A.事業年月 <= stringDate + 1
      where += " AND 事業年月 >= F月末月初取得(" + ActiveRecord::Base.sanitize(jigyoDate) + ", '1') "
      where += " AND 事業年月 <= ADD_MONTHS(F月末月初取得(" + ActiveRecord::Base.sanitize(jigyoDate) + ", '1'), 1)"
    end
    query += where
    # sort
    query +=" ORDER BY 組織コード"; 
    arrSOSIKI = Array.new;    
    hashSOSIKI = Hash.new;
    hashSOSIKI = @connection.ExecuteSelectQuery(query);
    index = 0;
    hashSOSIKI.each do |hashValue|
      record = Sosikimasuta.new("");
      record.puts(hashValue);
      arrSOSIKI[index] = record;
      index = index + 1;
    end
    
    return arrSOSIKI    
end
  
def self.getTantoList
    @connection = Connection.new();
    #Tantogroupmasuta
    query = "SELECT  担当者コード"
    query +="       , 担当者コード || ' : ' || 担当者名称 AS 担当者名称"
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
    # sort
    query +=" ORDER BY 担当者コード"; 
    arrTANTOSYA = Array.new;    
    hashTANTOSYA = Hash.new;
    hashTANTOSYA = @connection.ExecuteSelectQuery(query);
    index = 0;
    hashTANTOSYA.each do |hashValue|
      record = Tantosyamasuta.new("");
      record.puts(hashValue);
      arrTANTOSYA[index] = record;
      index = index + 1;
    end
    
    return arrTANTOSYA    
  end
  
  def self.updateForm(arrDeletes,arrUpdates,arrAddnews)
        @connection = Connection.new();
        # execute query for update, delete, insert
        conn = @connection.CreateConnect();
        results = "0"
        begin
          @TANTOUSYACODE=nil#担当者コード
          @TANTOUMEISYOU=nil#担当者名称
          @KAISIDATE=nil#開始日
          @SYURYOUDATE=nil#終了日
          @PASS=nil#パスワード
          @PASWORDUPDATEDATE=nil#パスワード更新
          @SOSEKICODE=nil#組織コード
          @TANTOUGROUPCODE=nil#担当グループコード
          @LOGINUSE=nil#ログインユーザー
          @FOCUSMENU=nil#フォーカス＿メニューコー
          @SYAINKUBUN=nil#社員区
          @KOUSINTANTOUSYACODE=nil#更新担当者コード  
          @GETPROGID=nil#更新プログラム 
          sysdate = @connection.GetSystemDate;
          sysdateString = "TO_DATE('" + sysdate + "','YYYY/MM/DD HH24:MI:SS')";
          @KOUSINJISTU=sysdateString#更新日時
          @NYURYOKUJISTU=sysdateString# 入力日時
          
          #Insert table
          insertQuery = "INSERT INTO 担当者マスタ(担当者コード, 担当者名称,開始日, 終了日, パスワード, パスワード更新日, 組織コード, 担当グループコード, ログインユーザー, フォーカス＿メニューコード, 社員区分, 更新担当者コード, 更新プログラム, 更新日時, 入力日時)"
          insertQuery += "VALUES(:TANTOUSYACODE,:TANTOUMEISYOU,:KAISIDATE,:SYURYOUDATE,:PASS,:PASWORDUPDATEDATE,:SOSEKICODE,:TANTOUGROUPCODE,:LOGINUSE,:FOCUSMENU,:SYAINKUBUN,:KOUSINTANTOUSYACODE,:GETPROGID,"+ sysdateString +","+ sysdateString +")";
          arrAddnews.each do |arrAddnew|
            @TANTOUSYACODE=arrAddnew[0]#担当者コード
            @TANTOUMEISYOU=arrAddnew[1]#担当者名称
            @KAISIDATE=arrAddnew[2]#開始日
            @SYURYOUDATE=arrAddnew[3]#終了日
            @PASS=arrAddnew[4]#パスワード
            @PASWORDUPDATEDATE=arrAddnew[5]#パスワード更新
            @SOSEKICODE=arrAddnew[6]#組織コード
            @TANTOUGROUPCODE=arrAddnew[7]#担当グループコード
            @LOGINUSE=arrAddnew[8]#ログインユーザー
            @FOCUSMENU=arrAddnew[9]#フォーカス＿メニューコー
            @SYAINKUBUN=arrAddnew[10]#社員区
            @KOUSINTANTOUSYACODE=arrAddnew[11]#更新担当者コード  
            @GETPROGID=arrAddnew[12]#更新プログラム 
            Rails.logger.info 'AddnewExecute: ' + @TANTOUSYACODE+ "," +@TANTOUMEISYOU+ "," +@KAISIDATE+ "," +@SYURYOUDATE+ "," +@PASS+ "," +@PASWORDUPDATEDATE+ "," +@SOSEKICODE+ "," +@TANTOUGROUPCODE+ "," +@LOGINUSE+ "," +@FOCUSMENU+ "," +@SYAINKUBUN+ "," +@KOUSINTANTOUSYACODE+ "," +@GETPROGID+ "," +@KOUSINJISTU+ "," +@NYURYOKUJISTU
            
            cursor = conn.parse(insertQuery);
            # bind by position
            cursor.bind_param(':TANTOUSYACODE', @TANTOUSYACODE)
            cursor.bind_param(':TANTOUMEISYOU', @TANTOUMEISYOU) 
            cursor.bind_param(':KAISIDATE', @KAISIDATE) 
            cursor.bind_param(':SYURYOUDATE', @SYURYOUDATE) 
            cursor.bind_param(':PASS', @PASS) 
            cursor.bind_param(':PASWORDUPDATEDATE', @PASWORDUPDATEDATE) 
            cursor.bind_param(':SOSEKICODE', @SOSEKICODE)
            cursor.bind_param(':TANTOUGROUPCODE', @TANTOUGROUPCODE) 
            cursor.bind_param(':LOGINUSE', @LOGINUSE) 
            cursor.bind_param(':FOCUSMENU', @FOCUSMENU) 
            cursor.bind_param(':SYAINKUBUN', @SYAINKUBUN) 
            cursor.bind_param(':KOUSINTANTOUSYACODE', @KOUSINTANTOUSYACODE) 
            cursor.bind_param(':GETPROGID', @GETPROGID) 
            cursor.exec
            cursor.close();
          end
          
          #Update table
          updateQuery = "UPDATE 担当者マスタ "
          updateQuery += " SET 担当者名称 = :TANTOUMEISYOU";
          updateQuery += " , 終了日 = :SYURYOUDATE";
          updateQuery += " , パスワード = :PASS";
          updateQuery += " , 組織コード = :SOSEKICODE";
          updateQuery += " , 担当グループコード = :TANTOUGROUPCODE";
          updateQuery += " , ログインユーザー = :LOGINUSE";
          updateQuery += " , フォーカス＿メニューコード = :FOCUSMENU";
          updateQuery += " , 社員区分 = :SYAINKUBUN";
          updateQuery += ", 更新担当者コード = :KOUSINTANTOUSYACODE";
          updateQuery += ", 更新日時 = " + sysdateString; 
          updateQuery +=" WHERE 担当者コード = :TANTOUSYACODE"
          updateQuery +=" AND 開始日 = :KAISIDATE"
          arrUpdates.each do |arrUpdate|
            @TANTOUSYACODE=arrUpdate[0]#担当者コード
            @TANTOUMEISYOU=arrUpdate[1]#担当者名称
            @KAISIDATE=arrUpdate[2]#開始日
            @SYURYOUDATE=arrUpdate[3]#終了日
            @PASS=arrUpdate[4]#パスワード
            @SOSEKICODE=arrUpdate[6]#組織コード
            @TANTOUGROUPCODE=arrUpdate[7]#担当グループコード
            @LOGINUSE=arrUpdate[8]#ログインユーザー
            @FOCUSMENU=arrUpdate[9]#フォーカス＿メニューコー
            @SYAINKUBUN=arrUpdate[10]#社員区分
            @KOUSINTANTOUSYACODE=arrUpdate[11]#更新担当者コード  
            Rails.logger.info 'UpdateExecute: ' + @TANTOUSYACODE+ "," +@TANTOUMEISYOU+ "," +@KAISIDATE+ "," +@SYURYOUDATE+ "," +@PASS+ "," +@SOSEKICODE+ "," +@TANTOUGROUPCODE+ "," +@LOGINUSE+ "," +@FOCUSMENU+ "," +@SYAINKUBUN+ "," +@KOUSINTANTOUSYACODE
            
            cursor = conn.parse(updateQuery);
            # bind by position
            cursor.bind_param(':TANTOUSYACODE', @TANTOUSYACODE)
            cursor.bind_param(':TANTOUMEISYOU', @TANTOUMEISYOU) 
            cursor.bind_param(':KAISIDATE', @KAISIDATE) 
            cursor.bind_param(':SYURYOUDATE', @SYURYOUDATE) 
            cursor.bind_param(':PASS', @PASS) 
            cursor.bind_param(':SOSEKICODE', @SOSEKICODE)
            cursor.bind_param(':TANTOUGROUPCODE', @TANTOUGROUPCODE) 
            cursor.bind_param(':LOGINUSE', @LOGINUSE) 
            cursor.bind_param(':FOCUSMENU', @FOCUSMENU) 
            cursor.bind_param(':SYAINKUBUN', @SYAINKUBUN) 
            cursor.bind_param(':KOUSINTANTOUSYACODE', @KOUSINTANTOUSYACODE) 
            cursor.exec
            cursor.close();
          end
          
          #Delete table
          deleteQuery = "DELETE FROM 担当者マスタ"
          deleteQuery +=" WHERE 担当者コード = :TANTOUSYACODE"
          deleteQuery +=" AND 開始日 = :KAISIDATE"
          arrDeletes.each do |arrDelete|
            @TANTOUSYACODE=arrDelete[0]#担当者コード
            @KAISIDATE=arrDelete[1]#開始日
            Rails.logger.info 'DeleteExecute: ' + @TANTOUSYACODE+ "," +@KAISIDATE
            
            cursor = conn.parse(deleteQuery);
            # bind by position
            cursor.bind_param(':TANTOUSYACODE', @TANTOUSYACODE)
            cursor.bind_param(':KAISIDATE', @KAISIDATE) 
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
  
def self.getTantoName(tantoCode,kaisiDate)
     @connection = Connection.new();
     #担当者マスタ
     query = "SELECT  count(*) AS COUNT"
     query +="   FROM 担当者マスタ a"
     query +="   WHERE  a.担当者コード  = '#{tantoCode}'"
     query +=" AND a.開始日 = '#{kaisiDate}'"
     returnvalue=@connection.ExecuteSelectQueryOne(query)
     return returnvalue["COUNT"];  
  end
  
end