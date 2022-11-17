#!/bin/env ruby
# encoding: utf-8
class LoginController < ApplicationController
  def self.GetVersion
      return "ver.1.00.00";
  end
  
  def index
     @connection = Connection.new();
     @pageTitle = "login ログイン" + LoginController.GetVersion + ")-[***]" + "- [" + @connection.DatabaseUserName + "@" + @connection.DatabaseServer + "]";
     @tantocode = params["tid"];
     message = params["message"];
     if !@tantocode.nil? && @tantocode != "" then
       @message = message;
     else
       @message = ""
     end
  end
   
   def logon
     #フォームにタントウコードを取得する。
     @tantocode = params["tantocode"];
     tantopwd = params["password"];
     @connection = Connection.new();
     #DBにsysdateを取得する
     sysdate = @connection.GetSystemDateFormat("YYYY/MM/DD");
     #データの担当者を取得する。
     tantoRec = @connection.GetTantoLogin(@tantocode, sysdate, tantopwd)
       if tantoRec.nil? || tantoRec[0].nil? then
         #データの担当者が無理。
         session["tantoname"] = ""
         session["tantocode"] = nil
         # format.html { render action: "index" }
         redirect_to :controller=>'login', :action => 'index', :tid => @tantocode, :message => "担当者コードまたはパスワードに誤りがあります。"
       else
         honjituDate = @connection.GetHonjitu
         if honjituDate > tantoRec[0]["パスワード更新日１"] then
          # 本日日付 ＞ パスワード使用終了日
          redirect_to :controller=>'login', :action => 'index', :tid => @tantocode, :message => "本日日付 ＞ パスワード使用終了日となっています。"
         else
          # ログインが成功
          session["tantoname"] = tantoRec[0]["担当者名称"] #@tantoname;
          session["tantocode"] = tantoRec[0]["担当者コード"] #@tantocode;
          session["tantogroupcode"] = tantoRec[0]["担当グループコード"] #@tantogroupcode;
          session["tantomenufocus"] = tantoRec[0]["フォーカス＿メニューコード"] #@tantomenufocus;
          #　担当者コードを取得する。 => 無理？
          query = "BEGIN PC共通.GC_TANTO_CD := '" + tantoRec[0]["担当者コード"] + "'; end;"
          @connection.ExecuteQuery(query)
          #termIDを作成する。
          termId = @connection.GetTermId
          session["termid"] = termId
          redirect_to :controller=>'menu', :action => 'index'
         end
       end
   end
   
   def logout
     session["tantocode"] = nil;
     session["tantogroupcode"] = ""
     session["tantomenufocus"] = ""
     session["tantoname"] = ""
     redirect_to :controller=>'login', :action => 'index'
   end
   
   def edit
     # requestにidを取得する。
     @tantoid = params["id"]
     @message = ""
     if request.post? then
       #　フォームにデータを取得する。
       @message = ""
       @tantocode = params["tantocode"];
       @tantoid =  @tantocode
       logintanto = session["tantocode"];
       if logintanto.nil? then
         logintanto = ""
       end
       tantopwd = params["password"];
       newtantopawd = params["newpassword"];
       @connection = Connection.new();
       sysdate = @connection.GetSystemDateFormat("YYYY/MM/DD");
       sysdate2 = @connection.GetSystemDate;
       sysdateString = "TO_DATE('" + sysdate2 + "','YYYY/MM/DD HH24:MI:SS')";
       tantoRec = @connection.GetTantoLogin(@tantocode, sysdate, tantopwd)
       respond_to do |format|
         if tantoRec.nil? || tantoRec[0].nil? then
            @message = "担当者コードまたはパスワードに誤りがあります。"
            format.html { render action: "edit" }
         else
           honjituDate = @connection.GetHonjitu
           if honjituDate > tantoRec[0]["パスワード更新日１"] then
             #本日日付 ＞ パスワード使用終了日となっている場合はパスワード更新日 = F本日日付取得
             updateQuery = "UPDATE 担当者マスタ "
             updateQuery += " SET パスワード更新日 = F本日日付取得"
             updateQuery += ", パスワード = '" + newtantopawd + "'"
             updateQuery += ", 更新担当者コード  = '" + logintanto + "'"
             updateQuery += ", 更新日時 = " + sysdateString;
           else
             updateQuery = "UPDATE 担当者マスタ "
             updateQuery += "SET パスワード = '" + newtantopawd + "'"
             updateQuery +=   ", 更新担当者コード  = '" + logintanto + "'"
             updateQuery += ", 更新日時 = " + sysdateString;
           end
           result = @connection.ExecuteQuery(updateQuery);
           if result == "0" then
             @message = "更新に成功しまた。"
             format.html { render action: "edit" }
           else
             @message = "更新に失敗しました。"
             format.html { render action: "edit" }
           end
         end
       end
     end
   end
end
