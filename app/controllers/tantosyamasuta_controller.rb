#!/bin/env ruby
# encoding: utf-8
require 'csv' # csvファイルを出力。
require 'iconv'
require 'tantosyabetugamenmasuta_model.rb'
require 'tantogroupmasuta_model.rb'
require 'tantosyamasuta_model.rb'
require 'gamenmasuta_model.rb'
require 'sosikimasuta_model.rb'
require 'menumasuta_model.rb'
require 'date'
class TantosyamasutaController < BaseController
    #================================================================
    #   名　称    TantosyamasutaController
    #   説　明    アクションを抑制しまた。
    #   補　足
    #   引　数 なし
    #   戻　値
    # (history)
    #   date         ver        name                      comments
    #  -------     -----      ----------------          -----------------
    #  2012.09.10  1.00.00     quandv118@gmail.com       新規作成
    #=================================================================
    def self.GetVersion
      return "ver.1.00.00";
    end
    
    def self.GetProgId
      return "mb_001"
    end
    
    def self.GetPageTitle(tantoname, user, dbserver)
      return TantosyamasutaController.GetProgId + " 担当者マスタ  (" + TantosyamasutaController.GetVersion + ")-[" + tantoname + "]" + "- [" + user + "@" + dbserver + "]";
    end
    
  def index
    @connection = Connection.new();
    tantoname = session["tantoname"]
    if tantoname.nil?
      tantoname = "***"
    end

    # 1. init
    # get title
    @pageTitle = TantosyamasutaController.GetPageTitle(tantoname, @connection.DatabaseUserName, @connection.DatabaseServer)

    # 
    # 基準日 = honjitu
    @honjitudate = @connection.GetHonjitu()
    Rails.logger.info 'dvquan.@honjitudate: ' + @honjitudate.strftime("%Y/%m/%d %H:%M:%S")
        
    #2. create query
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
    
    #UPDATE======================================================
    where = ""
    # 3. get search data
    @tantogroupcode = Publicfunction.pf_nvl_string(params["tantogroupcode"], "")
    @tantocode = Publicfunction.pf_nvl_string(params["tantocode"], "")
    param = params[:input_form]
    if param.nil? then
      @sosikicode = ""
    else
      @sosikicode = Publicfunction.pf_nvl_string(param["組織コード"], "")
    end
    @searchtext = Publicfunction.pf_nvl_string(params["tantoname"], "")
    @seachoption = Publicfunction.pf_nvl_string(params["searchoption"], "0")
    @kinjundatestring = Publicfunction.pf_nvl_string(params["kijiundate"], "")   
    if @tantogroupcode != "" then
      where += " AND a.担当グループコード = " + ActiveRecord::Base.sanitize(@tantogroupcode)
    end

    if @sosikicode != "" then
      where += " AND a.組織コード = " + ActiveRecord::Base.sanitize(@sosikicode)
    end
        
    if @tantocode != "" then
      where += " AND a.担当者コード = " + ActiveRecord::Base.sanitize(@tantocode)
    end

    if @searchtext != "" then     
      #F曖昧変換
      searchtext_temp = ActiveRecord::Base.sanitize(@searchtext)
      searchtext_temp = Publicfunction.pf_aimai_henkan(searchtext_temp)
      case @seachoption
        when "1" #1:部分一致
          where += " AND regexp_like(a.担当者名称, '" + searchtext_temp + "')"
        when "2" #2:前方一致
          where += " AND regexp_like(a.担当者名称, '^" + searchtext_temp + "')"
        when "3" #3:後方一致
          where += " AND regexp_like(a.担当者名称, '" + searchtext_temp + "$')"
      end
    end
    
    
    # kijun date
    if @kinjundatestring != "" then
      begin
        @kijundate = Date.parse(@kinjundatestring)
        where += " AND a.開始日 <= " + ActiveRecord::Base.sanitize(@kijundate)
        where += " AND a.終了日 >= " + ActiveRecord::Base.sanitize(@kijundate)
      rescue
         #do something if invalid
        @kijundate = @honjitudate
      end

      Rails.logger.info 'dvquan.@kinjundatestring: ' + @kijundate.strftime("%Y/%m/%d")
    else
      @kijundate = @honjitudate
      Rails.logger.info 'dvquan.@kinjundatestring: NULL'
    end
    # ls_where  = ls_where  + " and a.開始日 <= to_date('" + string(ldt_kijunbi , "YYYY/MM/DD") + "' , 'YYYY/MM/DD')"
    # ls_where  = ls_where  + " and to_date('" + string(ldt_kijunbi , "YYYY/MM/DD") + "' , 'YYYY/MM/DD') <= a.終了日"  

    # add where
    query += where
    Rails.logger.info 'dvquan.where: ' + where
      
    @models = Array.new;    
    @models1 = Hash.new;
    @models1 = @connection.ExecuteSelectQuery(query);
    index = 0;
    @models1.each do |hashValue|
      record = Tantosyamasuta.new("");
      record.puts(hashValue);
      @models[index] = record;
      index = index + 1;
    end

    @message = params[:notice];
    if @models.nil? || @models.size < 1 then
      @message = "該当データがありません。"
    end
    # ADD BY HUYENNM 21-9-2012
    @models.sort! { |a,b| a.担当者コード <=> b.担当者コード }
    # END ADD
    #4. Create csv
    # begin using csv
    header = '担当者コード, 担当者名称, 開始日, 終了日, パスワード, パスワード更新日, 組織コード, 組織名称, 担当グループコード, 担当グループ名称, ログインユーザー, フォーカス＿メニューコード, メニュー名称, 社員区分, 更新担当者コード, 更新プログラム, 更新日時, 入力日時, 担当グループコード'
    csv_string = header    
    @models.each do |model|
      if model.更新担当者コード.nil? then
        model.更新担当者コード = ""
      end
      
      if model.更新プログラム.nil? then
        model.更新プログラム = ""
      end
      
      if model.担当グループコード.nil? then
        model.担当グループコード = ""
      end

      line = '"' + model.担当者コード + '"'
      line += ',"' + model.担当者名称 + '"'
      line += ',"' + model.開始日.to_formatted_s(:default) + '"'
      line += ',"' + model.終了日.to_formatted_s(:default) + '"'
      line += ',"' + model.パスワード + '"'
      line += ',"' + model.パスワード更新日.to_formatted_s(:default) + '"'
      line += ',"' + Publicfunction.pf_nvl_string(model.組織コード, "") + '"'
      line += ',"' + Publicfunction.pf_nvl_string(model.組織名称, "") + '"'
      line += ',"' + model.担当グループコード + '"'
      line += ',"' + Publicfunction.pf_nvl_string(model.担当グループ名称, "") + '"'
      line += ',"' + Publicfunction.pf_nvl_string(model.ログインユーザー, "") + '"'
      line += ',"' + Publicfunction.pf_nvl_string(model.フォーカス_メニューコード, "") + '"'
      line += ',"' + Publicfunction.pf_nvl_string(model.メニュー名称, "") + '"'
      line += ',"' + Publicfunction.pf_nvl_string(model.社員区分, "") + '"'
      line += ',"' + Publicfunction.pf_nvl_string(model.更新担当者コード, "") + '"'
      line += ',"' + Publicfunction.pf_nvl_string(model.更新プログラム, "") + '"'
      if !model.更新日時.nil? then
        line += ',"' + model.更新日時.to_formatted_s(:default) + '"'
      else
        line += ',"' + ' "'
      end
      
      if !model.入力日時.nil? then
        line += ',"' + model.入力日時.to_formatted_s(:default) + '"'
      else
        line += ',"' + '"'
      end

      csv_string += "\r\n" + line;
    end
    # csv_string = lines
    # end using csv
    
    #5. Get table references
    @tantoGroupList = GetTantoGroupList()
    @tantoList = GetTantoList()
    @sosikiList = GetSosikiListWithStringDate(@kijundate)
    #end get list tanto group
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @models }
      # format.csv { send_data :csv => @models.to_csv(@models)}
      # format.csv { render :csv => @models}        
      @fileName=Iconv.conv('shift-jis', 'utf-8', "担当者マスタ.csv");
      format.csv { send_data(Iconv.conv('shift-jis//IGNORE', 'utf-8', csv_string), :filename => @fileName, :type => "text/csv",  :charset => "shift-jis") }
    end
  end  
  
  #-------------------------------- NEW COPY ------------------------------------
  def create
    @connection = Connection.new();
    @model = Tantosyamasuta.new("");
    sysdate = @connection.GetSystemDate;
    sysdateString = "TO_DATE('" + sysdate + "','YYYY/MM/DD HH24:MI:SS')";
    tantoCode = session["tantocode"];
    if tantoCode.nil?
      tantoCode = " "
    end
  
    # フォームのデータを取ります。params[フォーム名刺]
    # get form
    param = params[:input_form]
    # get element in form
    @model.担当者コード = Publicfunction.pf_nvl_string(param[:担当者コード], "");
    @model.担当者名称 = Publicfunction.pf_nvl_string(param[:担当者名称], "");
    @model.パスワード = Publicfunction.pf_nvl_string(param[:パスワード], "");
    @model.組織コード = Publicfunction.pf_nvl_string(param[:組織コード], "");
    @model.担当グループコード = Publicfunction.pf_nvl_string(param[:担当グループコード], "");
    @model.ログインユーザー = Publicfunction.pf_nvl_string(param[:ログインユーザー], "");
    @model.フォーカス_メニューコード = Publicfunction.pf_nvl_string(param[:フォーカス_メニューコード], "");
    @model.社員区分 = Publicfunction.pf_nvl_string(param[:社員区分], "");
     # Date process
    lsKaishiDateString = Publicfunction.pf_nvl_string(param[:開始日], "1900/01/01");
    lsShuryouDateString = Publicfunction.pf_nvl_string(param[:終了日], "1900/01/01");
    lsUpdateDateString = Publicfunction.pf_nvl_string(param[:パスワード更新日], "1900/01/01");
    logger.info 'dvquan.query: tantosyanmasuta.lsKaishiDateString ' + lsKaishiDateString + " lsShuryouDateString" + lsShuryouDateString;
    @model.開始日 = Date.parse(lsKaishiDateString)
    @model.終了日 = Date.parse(lsShuryouDateString)
    @model.パスワード更新日 = Date.parse(lsUpdateDateString)
    lsKaishiDateString = "TO_DATE('" + lsKaishiDateString + "','YYYY/MM/DD')";
    lsShuryouDateString = "TO_DATE('" + lsShuryouDateString + "','YYYY/MM/DD')";
    lsUpdateDateString = "TO_DATE('" + lsUpdateDateString + "','YYYY/MM/DD')";    
      
    #@model.開始日
    @model.更新担当者コード = tantoCode;
    @model.更新プログラム = TantosyabetugamenmasutaController.GetProgId;
    insertQuery = "INSERT INTO 担当者マスタ(担当者コード, 担当者名称,開始日, 終了日, パスワード, パスワード更新日, 組織コード, 担当グループコード, ログインユーザー, フォーカス＿メニューコード, 社員区分, 更新担当者コード, 更新プログラム, 更新日時, 入力日時)"
    insertQuery += "VALUES( ";
    insertQuery += " " + ActiveRecord::Base.sanitize(@model.担当者コード) + "";
    insertQuery += ", " + ActiveRecord::Base.sanitize(@model.担当者名称) + "";
    insertQuery += ", " + lsKaishiDateString + "";
    insertQuery += ", " + lsShuryouDateString + "";
    insertQuery += ", " + ActiveRecord::Base.sanitize(@model.パスワード) + "";
    insertQuery += ", " + lsUpdateDateString + "";
    
    insertQuery += ", " + ActiveRecord::Base.sanitize(@model.組織コード) + "";
    insertQuery += ", " + ActiveRecord::Base.sanitize(@model.担当グループコード) + "";
    insertQuery += ", " + ActiveRecord::Base.sanitize(@model.ログインユーザー) + "";
    insertQuery += ", " + ActiveRecord::Base.sanitize(@model.フォーカス_メニューコード) + "";
    insertQuery += ", " + ActiveRecord::Base.sanitize(@model.社員区分) + "";
    
    insertQuery += ", '" + @model.更新担当者コード + "'";
    insertQuery += ", '" + @model.更新プログラム + "'";
    insertQuery += ", " + sysdateString;
    insertQuery += ", " + sysdateString;    
    insertQuery += " )";
  
    
    # references tables
    @tantoGroupList = GetTantoGroupList()
    @tantoList = GetTantoList()
    @sosikiList = GetSosikiListWithStringDate(@kijundate)
    @focusmenuList = GetFocusMenuListWithTantoGroup(@model.担当グループコード)
    
    respond_to do |format|
        result = @connection.ExecuteQuery(insertQuery);
        @saveMessage = "RecordUpdated!";
        # redirect_to :controller=>'seisankojomasuta', :action => 'index'
        logger.info 'dvquan.query: tantosyamasuta.create ' + result;
        if result == "0"
          @model.message = "追加に成功しまた。";
          idString = @model.担当者コード + "," + @model.開始日.strftime("%Y-%m-%d")
          format.html { redirect_to :controller => "tantosyamasuta", :action => "show", :id => idString, notice: '追加に成功しまた.' };
          format.json { head :no_content };
        else
          @model.message = "更新に失敗しました。";
          @model.action_name = "new"
          format.html { render action: "new" }
          #format.json { render :json => {:saveMessage => @saveMessage, :error => '1'} }
        end       
      end
  end
  
  def new
    # add new record.
    @connection = Connection.new();
    tantoname = session["tantoname"]
    if tantoname.nil?
      tantoname = "  "
    end
    
    # 1. INIT
    # change page title of page
    @pageTitle = TantosyamasutaController.GetPageTitle(tantoname, @connection.DatabaseUserName, @connection.DatabaseServer)
    mode = params[:mode]
    @model = Tantosyamasuta.new("");
    @honjitudate = @connection.GetHonjitu()
    
    # 2. GET DATA
    if mode == "1" then
      # copy button
      # get id from request.
      @id = Publicfunction.pf_nvl_string(params[:id], "");
      #process id (id contains 担当者コード and 画面プログラム)
      idList = Array.new
      idList = Publicfunction.pf_csv_cut(@id)
      @tantocode = ""
      @kaishidatestring = ""
      if idList.size > 0 then
        @tantocode = idList[0]
        logger.info "dvquan.@tantocode: " + @tantocode
      end
      
      if idList.size > 1 then
        @kaishidatestring = idList[1]
        begin
          kaishidate = Date.parse(@kaishidatestring)
        rescue
           #do something if invalid
          kijundate = Date.parse("1900/01/01")
        end
        logger.info "dvquan.kaishidatestring: " + @kaishidatestring
      else
          kijundate = Date.parse("1900/01/01")
      end
      
      if !@id.nil? then
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
        query +="       , F事業年月取得(TO_DATE('" + @honjitudate.strftime("%Y/%m/%d") + "', 'YYYY/MM/DD')) AS 事業年月"
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
        # add to fin
        query +="   AND a.担当者コード = '" + @tantocode +"'"
        query +="   AND a.開始日 = F担当者＿開始日取得('" + @tantocode +"', " + ActiveRecord::Base.sanitize(kaishidate) + ")"
        
        records = @connection.ExecuteSelectQuery(query)
        @model = Tantosyamasuta.new("");    
  
        if !records.nil? && !records[0].nil?
          @model.puts(records[0]);
        end 
      end
    else
      #INIT Views
      # @honjitudate = @connection.GetHonjitu()
      @model.開始日 = @honjitudate
      @model.パスワード更新日 = @honjitudate
    end
    
    #3. references tables
    @tantoGroupList = GetTantoGroupList()
    @tantoList = GetTantoList()
    @sosikiList = GetSosikiListWithStringDate(@kijundate)
    @focusmenuList = GetFocusMenuListWithTantoGroup(@model.担当グループコード)
    @model.action_name = "new"
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @model }
    end
  end

#------------------------------------------- SHOW -------------------------
  
  def show
    @connection = Connection.new();
    # ajax
    id = Publicfunction.pf_nvl_string(params[:id], "")
    if id == "update_sosiki" then
          # ajax function
          kijun_date_string = Publicfunction.pf_nvl_string(params[:kijun_date], "")
          if kijun_date_string != "" then
            begin
              kijundate = Date.parse(kijun_date_string)
            rescue
               #do something if invalid
              kijundate = Date.parse("1900/01/01")
            end
          else
            kijundate = @connection.GetHonjitu()
          end
          logger.info 'dvquan.query: show kijundate' + kijundate.strftime("%Y/%m/%d")
          @sosikiList = GetSosikiListWithStringDate(kijundate)
          render :partial => "sosikilist", :object => @sosikiList
    else
      if id == "update_menulist" then
        # ajax function
        tantogroupcode = Publicfunction.pf_nvl_string(params[:ajax_tantogroup_code], "")
        logger.info 'dvquan.query: show update_menulist' + tantogroupcode
        @focusmenuList = GetFocusMenuListWithTantoGroup(tantogroupcode)
        render :partial => "focusmenulist", :object => @focusmenuList
      else
        # show action
        # @connection = Connection.new();
        tantoname = session["tantoname"]
        if tantoname.nil?
          tantoname = "*"
        end
        # update page title
        @pageTitle = TantosyamasutaController.GetPageTitle(tantoname, @connection.DatabaseUserName, @connection.DatabaseServer)
        
        # get honjitu date
        @honjitudate = @connection.GetHonjitu()
        # get id from request.
        @id = Publicfunction.pf_nvl_string(params[:id], "");
        #process id (id contains 担当者コード and 画面プログラム)
        idList = Array.new
        idList = Publicfunction.pf_csv_cut(@id)
        @tantocode = ""
        @kaishidatestring = ""
        if idList.size > 0 then
          @tantocode = idList[0]
          logger.info "dvquan.@tantocode: " + @tantocode
        end
        
        if idList.size > 1 then
          @kaishidatestring = idList[1]
          begin
            kaishidate = Date.parse(@kaishidatestring)
          rescue
             #do something if invalid
            kijundate = Date.parse("1900/01/01")
          end
          logger.info "dvquan.kaishidatestring: " + @kaishidatestring
        else
            kijundate = Date.parse("1900/01/01")
        end
        
        # query
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
        query +="       , F事業年月取得(TO_DATE('" + @honjitudate.strftime("%Y/%m/%d") + "', 'YYYY/MM/DD') ) AS 事業年月"
        query +="   FROM 担当者マスタ a"
        query +="   , 担当グループマスタ b"
        query +="   , ( SELECT  e.組織コード"
        query +="           ,   e.組織名称"
        query +="           ,   e.事業年月"
        query +="       FROM    組織マスタ e"
        #WHERE    e."事業年月"  = to_date(to_char(:adt_jigyou , 'YYYY/MM/DD'))    
        query +="       WHERE    e.事業年月  = F事業年月取得(to_date('"+ @honjitudate.strftime("%Y/%m/%d") + "', 'YYYY/MM/DD') )"
        query +="     ) c"
        query +="   , メニューマスタ d"
        query +="   WHERE  a.担当グループコード       = b.担当グループコード(+) "
        query +="   AND a.組織コード             = c.組織コード(+)"
        query +="   AND a.担当グループコード       = d.担当グループコード(+)"
        query +="   AND a.フォーカス＿メニューコード = d.メニューコード(+)"
        # add to fin
        query +="   AND a.担当者コード = '" + @tantocode +"'"
        query +="   AND a.開始日 = F担当者＿開始日取得('" + @tantocode +"', " + ActiveRecord::Base.sanitize(kaishidate) + ")"
        records = @connection.ExecuteSelectQuery(query)
        @model = Tantosyamasuta.new("1");
        if !records.nil?
          @model.puts(records[0]);
        end
            
        @model.message = params[:notice];
        respond_to do |format|
          format.html # show.html.erb
          format.json { render json: @model }
        end
      end
    end
  end

  # ------------------------------ EDIT ACTION ------------------------------
  def edit
    @connection = Connection.new();
    tantoname = session["tantoname"]
    if tantoname.nil?
      tantoname = "  "
    end
    
    @pageTitle = TantosyamasutaController.GetPageTitle(tantoname, @connection.DatabaseUserName, @connection.DatabaseServer)
    # get id from request.
    # get honjitu date
    @honjitudate = @connection.GetHonjitu()
    # get id from request.
    @id = Publicfunction.pf_nvl_string(params[:id], "");
    #process id (id contains 担当者コード and 画面プログラム)
    idList = Array.new
    idList = Publicfunction.pf_csv_cut(@id)
    @tantocode = ""
    @kaishidatestring = ""
    if idList.size > 0 then
      @tantocode = idList[0]
      logger.info "dvquan.@tantocode: " + @tantocode
    end
    
    if idList.size > 1 then
      @kaishidatestring = idList[1]
      begin
        kaishidate = Date.parse(@kaishidatestring)
      rescue
         #do something if invalid
        kijundate = Date.parse("1900/01/01")
      end
      logger.info "dvquan.kaishidatestring: " + @kaishidatestring
    else
        kijundate = Date.parse("1900/01/01")
    end
    
    # query
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
    query +="       , TO_DATE(TO_CHAR(" + ActiveRecord::Base.sanitize(@honjitudate) + ", 'YYYY/MM/DD')) AS 事業年月"
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
    # add to fin
    query +="   AND a.担当者コード = '" + @tantocode +"'"
    query +="   AND a.開始日 = F担当者＿開始日取得('" + @tantocode +"', " + ActiveRecord::Base.sanitize(kaishidate) + ")"
        
    records = @connection.ExecuteSelectQuery(query)
    @model = Tantosyamasuta.new("1");
    #@kojomasuta.生産管轄工場コード= "DV007";
    if !records.nil?
      @model.puts(records[0]);
    end
    @tantoGroupList = GetTantoGroupList()
    @tantoList = GetTantoList()
    @sosikiList = GetSosikiListWithStringDate(@model.開始日)
    @focusmenuList = GetFocusMenuListWithTantoGroup(@model.担当グループコード)
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @model }
    end
  end
  
  def update
    @connection = Connection.new();
    tantoname = session["tantoname"]
    if tantoname.nil?
      tantoname = "***"
    end
    # 1. set page title
    @pageTitle = TantosyamasutaController.GetPageTitle(tantoname, @connection.DatabaseUserName, @connection.DatabaseServer)
    
    # 2. get id from request.
    # get honjitu date
    @honjitudate = @connection.GetHonjitu()
    # get id from request.
    @id = Publicfunction.pf_nvl_string(params[:id], "");
    #process id (id contains 担当者コード and 画面プログラム)
    idList = Array.new
    idList = Publicfunction.pf_csv_cut(@id)
    @tantocode = ""
    @kaishidatestring = ""
    if idList.size > 0 then
      @tantocode = idList[0]
      logger.info "dvquan.@tantocode: " + @tantocode
    end
    
    if idList.size > 1 then
      @kaishidatestring = idList[1]
      begin
        kaishidate = Date.parse(@kaishidatestring)
      rescue
         #do something if invalid
        kijundate = Date.parse("1900/01/01")
      end
      logger.info "dvquan.kaishidatestring: " + @kaishidatestring
    else
        kijundate = Date.parse("1900/01/01")
    end
    
    # 3 . Get record 
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
    query +="       , F事業年月取得(TO_DATE(TO_CHAR(" + ActiveRecord::Base.sanitize(@honjitudate) + ", 'YYYY/MM/DD')) ) AS 事業年月"
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
    # add to fin
    query +="   AND a.担当者コード = '" + @tantocode +"'"
    query +="   AND a.開始日 = F担当者＿開始日取得('" + @tantocode +"', " + ActiveRecord::Base.sanitize(kaishidate) + ")"
        
    records = @connection.ExecuteSelectQuery(query)
    @model = Tantosyamasuta.new("1");
    #@kojomasuta.生産管轄工場コード= "DV007";
    if !records.nil?
      @model.puts(records[0]);
    end
    
    #4. get form edit
    # フォームのデータを取ります。params[フォーム名刺]
    param = params[:input_form]
    #生産管轄工場マスタを変換します。
    sysdate = @connection.GetSystemDate;
    sysdateString = "TO_DATE('" + sysdate + "','YYYY/MM/DD HH24:MI:SS')";
    tantoCode = session["tantocode"];
    if tantoCode.nil?
      tantoCode = " "
    end
    
    # get element in form
    # @model.担当者コード = Publicfunction.pf_nvl_string(param[:担当者コード], "");
    @model.担当者名称 = Publicfunction.pf_nvl_string(param[:担当者名称], "");
    @model.パスワード = Publicfunction.pf_nvl_string(param[:パスワード], "");
    @model.組織コード = Publicfunction.pf_nvl_string(param[:組織コード], "");
    @model.担当グループコード = Publicfunction.pf_nvl_string(param[:担当グループコード], "");
    @model.ログインユーザー = Publicfunction.pf_nvl_string(param[:ログインユーザー], "");
    @model.フォーカス_メニューコード = Publicfunction.pf_nvl_string(param[:フォーカス_メニューコード], "");
    @model.社員区分 = Publicfunction.pf_nvl_string(param[:社員区分], "");
     # Date process
    # lsKaishiDateString = Publicfunction.pf_nvl_string(param[:開始日], "1900/01/01");
    lsShuryouDateString = Publicfunction.pf_nvl_string(param[:終了日], "1900/01/01");
    # logger.info 'dvquan.query: tantosyanmasuta.lsKaishiDateString ' + lsKaishiDateString + " lsShuryouDateString" + lsShuryouDateString;
    # @model.開始日 = Date.parse(lsKaishiDateString)
    @model.終了日 = Date.parse(lsShuryouDateString)
    # @model.パスワード更新日 = Date.parse(lsUpdateDateString)
    lsKaishiDateString = "TO_DATE('" + @model.開始日.strftime("%Y-%m-%d") + "','YYYY/MM/DD')";
    lsShuryouDateString = "TO_DATE('" + lsShuryouDateString + "','YYYY/MM/DD')";
    
    # create query update
    updateQuery = "UPDATE 担当者マスタ "
    updateQuery += " SET 担当者名称 = " + ActiveRecord::Base.sanitize(@model.担当者名称) + "";
    updateQuery += " , 終了日 = " + lsShuryouDateString + "";
    updateQuery += " , パスワード = " + ActiveRecord::Base.sanitize(@model.パスワード) + "";
    updateQuery += " , 組織コード = " + ActiveRecord::Base.sanitize(@model.組織コード) + "";
    updateQuery += " , 担当グループコード = " + ActiveRecord::Base.sanitize(@model.担当グループコード) + "";
    updateQuery += " , 社員区分 = " + ActiveRecord::Base.sanitize(@model.社員区分) + "";
    updateQuery += " , ログインユーザー = " + ActiveRecord::Base.sanitize(@model.ログインユーザー) + "";
    updateQuery += " , フォーカス＿メニューコード = " + ActiveRecord::Base.sanitize(@model.フォーカス_メニューコード) + "";
    updateQuery += ", 更新担当者コード = '" + tantoCode + "'";
    updateQuery += ", 更新日時 = " + sysdateString; 
    updateQuery +=" WHERE 担当者コード = '" + @tantocode + "'"
    updateQuery +=" AND 開始日 = " + lsKaishiDateString
    
    # 5. update and render action.
    respond_to do |format|
      begin
          result = @connection.ExecuteQuery(updateQuery);
          # redirect_to :controller=>'seisankankatukoujoumasuta', :action => 'show'
          if result == "0"
            @model.message ="1232"
            idString = @model.担当者コード + "," + @model.開始日.strftime("%Y-%m-%d")
            format.html { redirect_to :controller => "tantosyamasuta", :action => "show", :id => idString, notice: '更新に成功しまた.' };
            format.json { head :no_content };
          else
            @model.message = "更新に失敗しました。";
            format.html { render action: "edit" }
          end
      rescue
        #エラーが起こります。
        @saveMessage = "更新に失敗しました。"
        format.html { render action: "edit" }
        #format.json { render :json => {:saveMessage => @saveMessage, :error => '1'} }
      ensure 
        # 終わる。
      end
    end
  end
  # ------------------------------ DELETE ACTION ----------------------------
  def destroy
    @connection = Connection.new();
    # get id from request.
    @id = Publicfunction.pf_nvl_string(params[:id], "");
    #process id (id contains 担当者コード and kaishidate)
    idList = Array.new
    idList = Publicfunction.pf_csv_cut(@id)
    @tantocode = ""
    @kaishidatestring = ""
    if idList.size > 0 then
      @tantocode = idList[0]
      logger.info "dvquan.@tantocode: " + @tantocode
    end
    
    if idList.size > 1 then
      @kaishidatestring = idList[1]
      begin
        kaishidate = Date.parse(@kaishidatestring)
      rescue
         #do something if invalid
        kijundate = Date.parse("1900/01/01")
      end
      logger.info "dvquan.kaishidatestring: " + @kaishidatestring
    else
        kijundate = Date.parse("1900/01/01")
    end   
    deleteQuery = "DELETE FROM 担当者マスタ"
    deleteQuery +=" WHERE 担当者コード = '" + @tantocode + "'"
    deleteQuery +=" AND 開始日 = " + ActiveRecord::Base.sanitize(kaishidate)

    respond_to do |format|    
      begin
        result = @connection.ExecuteQuery(deleteQuery);
        if result == "0"
          format.html { redirect_to :controller => "tantosyamasuta", :action => "index", notice: '削除に成功しました。'}
          format.json { head :no_content }
        else
          format.html { redirect_to :controller => "tantosyamasuta", :action => "index", notice: '削除に失敗しました。'}
          format.json { head :no_content }
        end
      rescue
        format.html { redirect_to :controller => "tantosyamasuta", :action => "index", notice: '削除に失敗しました。'}
        format.json { head :no_content }
      ensure 
      end
    end
    
  end
  # ------------------------------ Functioｎ ---------------------------------
  def GetTantoGroupList
    connection = Connection.new();
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
  
  def GetTantoList
    connection = Connection.new();
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
    models = Array.new;    
    models1 = Hash.new;
    models1 = connection.ExecuteSelectQuery(query);
    index = 0;
    models1.each do |hashValue|
      record = Tantosyamasuta.new("");
      record.puts(hashValue);
      models[index] = record;
      index = index + 1;
    end
    
    return models    
  end
  
  def GetSosikiListWithStringDate(kijundate)
    connection = Connection.new();
    #where
    where = ""
    if !kijundate.nil? then
      # get jigyodate from kijundate
      jigyoDate = Publicfunction.pf_GetJigyoDate(connection, kijundate)
      # stringDate 
      #事業年月 >= stringDate && A.事業年月 <= stringDate + 1
      where = " WHERE 事業年月 >= F月末月初取得(" + ActiveRecord::Base.sanitize(jigyoDate) + ", '1') "
      where += " AND 事業年月 <= ADD_MONTHS(F月末月初取得(" + ActiveRecord::Base.sanitize(jigyoDate) + ", '1'), 1)"
    end
    
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
    query += where
    # sort
    query +=" ORDER BY 組織コード"; 
    models = Array.new;    
    models1 = Hash.new;
    models1 = connection.ExecuteSelectQuery(query);
    index = 0;
    models1.each do |hashValue|
      record = Sosikimasuta.new("");
      record.puts(hashValue);
      models[index] = record;
      index = index + 1;
    end
    
    return models    
  end
  
  def GetFocusMenuListWithTantoGroup(tantogroupcode)
    # メニューマスタ
    groupcode = Publicfunction.pf_nvl_string(tantogroupcode, "")
    where = ""
    if groupcode.nil? then
      where = " WHERE 1 = 0"
    else
      where = " WHERE 担当グループコード = '" + groupcode + "'"
    end
    
    connection = Connection.new();
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
    query += where
    # sort
    query +=" ORDER BY メニューコード"; 
    models = Array.new;    
    models1 = Hash.new;
    models1 = connection.ExecuteSelectQuery(query);
    index = 0;
    models1.each do |hashValue|
      record = Menumasuta.new("");
      record.puts(hashValue);
      models[index] = record;
      index = index + 1;
    end
    
    return models 
  end
end