#!/bin/env ruby
# encoding: utf-8
require 'csv' # csvファイルを出力。
require 'iconv'
require 'tantosyabetugamenmasuta_model.rb'
require 'tantogroupmasuta_model.rb'
require 'tantosyamasuta_model.rb'
require 'gamenmasuta_model.rb'
class TantosyabetugamenmasutaController < BaseController
	  #================================================================
	  #   名　称    TantosyabetugamenmasutaController
	  #   説　明    アクションを抑制しまた。
	  #   補　足
	  #   引　数 なし
	  #   戻　値
	  # (history)
	  #   date         ver        name                      comments
	  #  -------     -----      ----------------          -----------------
	  #  2012.09.05  1.00.00     quandv118@gmail.com       新規作成
	  #=================================================================
	  def self.GetVersion
	    return "ver.1.00.00";
	  end
	  
	  def self.GetProgId
	    return "mb_005"
	  end
	  
	  def self.GetPageTitle(tantoname, user, dbserver)
	    return TantosyabetugamenmasutaController.GetProgId + " 担当者別画面マスタ  (" + TantosyabetugamenmasutaController.GetVersion + ")-[" + tantoname + "]" + "- [" + user + "@" + dbserver + "]";
	  end

  def index
    @connection = Connection.new();
    tantoname = session["tantoname"]
    if tantoname.nil?
      tantoname = "***"
    end
    
    # @pageTitle = "mb_002 担当グループマスタ  (" + TantogroupmasutaController.GetVersion + ")-[" + tantoname + "]" + "- [" + @connection.DatabaseUserName + "@" + @connection.DatabaseServer + "]";
    @pageTitle = TantosyabetugamenmasutaController.GetPageTitle(tantoname, @connection.DatabaseUserName, @connection.DatabaseServer)
    query = "SELECT  a.担当者コード"
    query +="       , b.担当者名称"
    query +="       , a.画面プログラム"
    query +="       , c.画面名称"
    query +="       , a.権限区分"
    query +="       , b.担当グループコード"
    query +="       , a.更新担当者コード"
    query +="      , a.更新プログラム"
    query +="      , a.更新日時"
    query +="      , a.入力日時 "
    query +="   FROM 担当者別画面マスタ a"
    query +="   , 担当者マスタ b"
    query +="   , 画面マスタ c"
    query +="   WHERE a.担当者コード = b.担当者コード(+)"
    query +="   AND b.開始日 = F担当者＿開始日取得(b.担当者コード, F本日日付取得)"
    query +="   AND a.画面プログラム = c.画面プログラム(+)"

    where = ""
    # get search data
    @tantogroupcode = Publicfunction.pf_nvl_string(params["tantogroupcode"], "")
    @tantocode = Publicfunction.pf_nvl_string(params["tantocode"], "")
    @searchtext = Publicfunction.pf_nvl_string(params["gamenname"], "")
    @seachoption = Publicfunction.pf_nvl_string(params["searchoption"], "0")
    
    if @tantogroupcode != "" then
      where += " AND b.担当グループコード = " + ActiveRecord::Base.sanitize(@tantogroupcode)
    end
    
    if @tantocode != "" then
      where += " AND a.担当者コード = " + ActiveRecord::Base.sanitize(@tantocode)
    end
    
    Rails.logger.info 'dvquan.tantocode: ' + @tantocode + " WHERE: " + where + " request: "

    if @searchtext != "" then     
      #F曖昧変換
      searchtext_temp = ActiveRecord::Base.sanitize(@searchtext)
      searchtext_temp = Publicfunction.pf_aimai_henkan(searchtext_temp)
      case @seachoption
        when "1"
          where += " AND regexp_like(c.画面名称, '" + searchtext_temp + "')"
        when "2"
          where += " AND regexp_like(c.画面名称, '^" + searchtext_temp + "')"
        when "3"
          where += " AND regexp_like(c.画面名称, '" + searchtext_temp + "$')"
      end
    end
    
    # add where
    query += where
    
    @models = Array.new;    
    @models1 = Hash.new;
    @models1 = @connection.ExecuteSelectQuery(query);
    index = 0;
    @models1.each do |hashValue|
      record = Tantosyabetugamenmasuta.new("");
      record.puts(hashValue);
      @models[index] = record;
      index = index + 1;
    end

    @message = params[:notice];
    if @models.nil? || @models.size < 1 then
      @message = "該当データがありません。"
    end
    # begin using csv
    header = '担当者コード, 担当者名称, 画面プログラム, 画面名称, 権限区分, 更新担当者コード, 更新プログラム, 更新日時, 入力日時, 担当グループコード'
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
      line += ',"' + model.画面プログラム + '"'
      line += ',"' + model.画面名称 + '"'
      line += ',"' + model.権限区分 + '"'
      line += ',"' + model.更新担当者コード + '"'
      line += ',"' + model.更新プログラム + '"'
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
      line += ',"' + model.担当グループコード + '"'
      csv_string += "\r\n" + line;
    end
    # csv_string = lines
    # end using csv
    
    #get list tanto group
    @tantoGroupList = GetTantoGroupList()
    @tantoList = GetTantoList()
    #end get list tanto group
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @models }
      # format.csv { send_data :csv => @models.to_csv(@models)}
      # format.csv { render :csv => @models}
      @fileName=Iconv.conv('shift-jis', 'utf-8', "担当者別画面マスタ.csv");
      format.csv { send_data(Iconv.conv('shift-jis//IGNORE', 'utf-8', csv_string), :filename => @fileName, :type => "text/csv",  :charset => "shift-jis") }
    end
  end
  
  def create
    @connection = Connection.new();
    @model = Tantosyabetugamenmasuta.new("");
    sysdate = @connection.GetSystemDate;
    sysdateString = "TO_DATE('" + sysdate + "','YYYY/MM/DD HH24:MI:SS')";
    tantoCode = session["tantocode"];
    if tantoCode.nil?
      tantoCode = " "
    end

    # フォームのデータを取ります。params[フォーム名刺]
    param = params[:input_form]
    @model.担当者コード = Publicfunction.pf_nvl_string(param[:担当者コード], "");
    @model.画面プログラム = Publicfunction.pf_nvl_string(param[:画面プログラム], "");
    @model.権限区分 = Publicfunction.pf_nvl_string(param[:権限区分], "-1");
    @model.更新担当者コード = tantoCode;
    @model.更新プログラム = TantosyabetugamenmasutaController.GetProgId;
    insertQuery = "INSERT INTO 担当者別画面マスタ(担当者コード, 画面プログラム,権限区分, 更新担当者コード, 更新プログラム, 更新日時, 入力日時)"
    insertQuery += "VALUES( ";
    insertQuery += " " + ActiveRecord::Base.sanitize(@model.担当者コード) + "";
    insertQuery += ", " + ActiveRecord::Base.sanitize(@model.画面プログラム) + "";
    insertQuery += ", " + ActiveRecord::Base.sanitize(@model.権限区分) + "";
    insertQuery += ", '" + @model.更新担当者コード + "'";
    insertQuery += ", '" + @model.更新プログラム + "'";
    insertQuery += ", " + sysdateString;
    insertQuery += ", " + sysdateString;    
    insertQuery += " )";
  
    
    # references tables
    @tantoList = GetTantoList()
    @gamenList = GetGamenListWithTanto("")
    respond_to do |format|
        result = @connection.ExecuteQuery(insertQuery);
        @saveMessage = "RecordUpdated!";
        # redirect_to :controller=>'seisankojomasuta', :action => 'index'
        logger.info 'dvquan.query: tantosyabetugamenmasuta.create ' + result;
        if result == "0"
          @model.message = "追加に成功しまた。";
          format.html { redirect_to :controller => "tantosyabetugamenmasuta", :action => "show", :id => @model.担当者コード + "," + @model.画面プログラム, notice: '追加に成功しまた.' };
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
    
    # change page title of page
    @pageTitle = TantosyabetugamenmasutaController.GetPageTitle(tantoname, @connection.DatabaseUserName, @connection.DatabaseServer)
    mode = params[:mode]
    @model = Tantosyabetugamenmasuta.new("");
    if mode == "1" then
      # copy button
      # get id from request.
      @id = Publicfunction.pf_nvl_string(params[:id], "");
      #process id (id contains 担当者コード and 画面プログラム)
      idList = Array.new
      idList = Publicfunction.pf_csv_cut(@id)
      @tantocode = ""
      @gamenprog = ""
      if idList.size > 0 then
        @tantocode = idList[0]
        logger.info "dvquan.@tantocode: " + @tantocode
      end
      
      if idList.size > 1 then
          @gamenprog = idList[1]
          logger.info "dvquan.gamenprog: " + @gamenprog
      end
      
      if !@id.nil? then
        query = "SELECT  担当者コード"
        query +="       , 画面プログラム"
        query +="       , 権限区分"
        query +="       , 更新担当者コード"
        query +="      , 更新プログラム"
        query +="      , 更新日時"
        query +="      , 入力日時 "
        query +="   FROM 担当者別画面マスタ";
        query +="   WHERE 担当者コード ='" + @tantocode + "'";
        query +="   AND 画面プログラム ='" + @gamenprog + "'";
        
        records = @connection.ExecuteSelectQuery(query)
        @model = Tantosyabetugamenmasuta.new("");    
  
        if !records.nil? && !records[0].nil?
          @model.puts(records[0]);
        end 
      end
    end
    
    # references tables
    @tantoList = GetTantoList()
    logger.info 'dvquan.query: tantosyabetugamenmasuta.create.tantocode ' + Publicfunction.pf_nvl_string(@model.担当者コード, "not fond");
    @gamenList = GetGamenListWithTanto(@tantocode)
    @model.action_name = "new"
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @model }
    end
  end

  def show
    id = Publicfunction.pf_nvl_string(params[:id], "")
    if id == "update_gamen" then
      # ajax function
      tantocode = Publicfunction.pf_nvl_string(params[:tanto_id], "Not found")
      logger.info 'dvquan.query: show'
      @gamenList = GetGamenListWithTanto(tantocode)
      render :partial => "gamenlist", :object => @gamenList
    else
      # show action
      @connection = Connection.new();
      tantoname = session["tantoname"]
      if tantoname.nil?
        tantoname = "*"
      end
      # update page title
      @pageTitle = TantosyabetugamenmasutaController.GetPageTitle(tantoname, @connection.DatabaseUserName, @connection.DatabaseServer)
      
      # get id from request.
      @id = Publicfunction.pf_nvl_string(params[:id], "");
      #process id (id contains 担当者コード and 画面プログラム)
      idList = Array.new
      idList = Publicfunction.pf_csv_cut(@id)
      @tantocode = ""
      @gamenprog = ""
      if idList.size > 0 then
        @tantocode = idList[0]
        logger.info "dvquan.@tantocode: " + @tantocode
      end
      
      if idList.size > 1 then
          @gamenprog = idList[1]
          logger.info "dvquan.gamenprog: " + @gamenprog
      end
      
      # query
      query = "SELECT  a.担当者コード"
      query +="       , b.担当者名称"
      query +="       , a.画面プログラム"
      query +="       , c.画面名称"
      query +="       , a.権限区分"
      query +="       , b.担当グループコード"
      query +="       , a.更新担当者コード"
      query +="      , a.更新プログラム"
      query +="      , a.更新日時"
      query +="      , a.入力日時 "
      query +="   FROM 担当者別画面マスタ a"
      query +="   , 担当者マスタ b"
      query +="   , 画面マスタ c"
      query +="   WHERE a.担当者コード = b.担当者コード(+)"
      query +="   AND b.開始日 = F担当者＿開始日取得(b.担当者コード, F本日日付取得)"
      query +="   AND a.画面プログラム = c.画面プログラム(+)"
      query +="   AND a.担当者コード ='" + @tantocode + "'";
      query +="   AND a.画面プログラム ='" + @gamenprog + "'";
      
      records = @connection.ExecuteSelectQuery(query)
      @model = Tantosyabetugamenmasuta.new("1");
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

  # ================ EDIT
  def edit
    @connection = Connection.new();
    tantoname = session["tantoname"]
    if tantoname.nil?
      tantoname = "  "
    end
    
    @pageTitle = TantosyabetugamenmasutaController.GetPageTitle(tantoname, @connection.DatabaseUserName, @connection.DatabaseServer)
    # get id from request.
    @id = Publicfunction.pf_nvl_string(params[:id], "");
    #process id (id contains 担当者コード and 画面プログラム)
    idList = Array.new
    idList = Publicfunction.pf_csv_cut(@id)
    @tantocode = ""
    @gamenprog = ""
    if idList.size > 0 then
      @tantocode = idList[0]
      logger.info "dvquan.@tantocode: " + @tantocode
    end
    
    if idList.size > 1 then
        @gamenprog = idList[1]
        logger.info "dvquan.gamenprog: " + @gamenprog
    end
    
    query = "SELECT  a.担当者コード"
    query +="       , b.担当者名称"
    query +="       , a.画面プログラム"
    query +="       , c.画面名称"
    query +="       , a.権限区分"
    query +="       , b.担当グループコード"
    query +="       , a.更新担当者コード"
    query +="      , a.更新プログラム"
    query +="      , a.更新日時"
    query +="      , a.入力日時 "
    query +="   FROM 担当者別画面マスタ a"
    query +="   , 担当者マスタ b"
    query +="   , 画面マスタ c"
    query +="   WHERE a.担当者コード = b.担当者コード(+)"
    query +="   AND b.開始日 = F担当者＿開始日取得(b.担当者コード, F本日日付取得)"
    query +="   AND a.画面プログラム = c.画面プログラム(+)"
    query +="   AND a.担当者コード ='" + @tantocode + "'";
    query +="   AND a.画面プログラム ='" + @gamenprog + "'";
        
    records = @connection.ExecuteSelectQuery(query)
    @model = Tantosyabetugamenmasuta.new("1");    
    #@kojomasuta.生産管轄工場コード= "DV007";
    if !records.nil?
      @model.puts(records[0]);
    end 
    
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
    @pageTitle = TantosyabetugamenmasutaController.GetPageTitle(tantoname, @connection.DatabaseUserName, @connection.DatabaseServer)
    
    # 2. get id from request.
    @id = Publicfunction.pf_nvl_string(params[:id], "");
    #process id (id contains 担当者コード and 画面プログラム)
    idList = Array.new
    idList = Publicfunction.pf_csv_cut(@id)
    @tantocode = ""
    @gamenprog = ""
    if idList.size > 0 then
      @tantocode = idList[0]
      logger.info "dvquan.@tantocode: " + @tantocode
    end
    
    if idList.size > 1 then
        @gamenprog = idList[1]
        logger.info "dvquan.gamenprog: " + @gamenprog
    end
    
    #3. Get record
    query = "SELECT  担当者コード"
    query +="       , 画面プログラム"
    query +="       , 権限区分"
    query +="       , 更新担当者コード"
    query +="      , 更新プログラム"
    query +="      , 更新日時"
    query +="      , 入力日時 "
    query +="   FROM 担当者別画面マスタ";
    query +="   WHERE 担当者コード ='" + @tantocode + "'";
    query +="   AND 画面プログラム ='" + @gamenprog + "'";
        
    records = @connection.ExecuteSelectQuery(query)
    @model = Tantosyabetugamenmasuta.new("1");
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
    
    # form
    @model.権限区分 = param[:権限区分];
    updateQuery = "UPDATE 担当者別画面マスタ "
    updateQuery += " SET 権限区分 = " + ActiveRecord::Base.sanitize(@model.権限区分) + "";
    updateQuery += ", 更新担当者コード = '" + tantoCode + "'";
    updateQuery += ", 更新日時 = " + sysdateString; 
    updateQuery += " WHERE 担当者コード = '" + @model.担当者コード + "'";    
    updateQuery += " AND 画面プログラム = '" + @model.画面プログラム + "'";
    
    # 5. update and render action.
    respond_to do |format|
      begin
          result = @connection.ExecuteQuery(updateQuery);
          # redirect_to :controller=>'seisankankatukoujoumasuta', :action => 'show'
          if result == "0"
            @model.message ="1232"
            idstring = @model.担当者コード + "," + @model.画面プログラム.strip
            format.html { redirect_to :controller => "tantosyabetugamenmasuta", :action => "show", :id => idstring, notice: '更新に成功しまた.' };
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
  
  def destroy
    #delete action
    @connection = Connection.new();
    # 1. get id from request.
    @id = Publicfunction.pf_nvl_string(params[:id], "");
    #process id (id contains 担当者コード and 画面プログラム)
    idList = Array.new
    idList = Publicfunction.pf_csv_cut(@id)
    @tantocode = ""
    @gamenprog = ""
    if idList.size > 0 then
      @tantocode = idList[0]
      logger.info "dvquan.@tantocode: " + @tantocode
    end
    
    if idList.size > 1 then
        @gamenprog = idList[1]
        logger.info "dvquan.gamenprog: " + @gamenprog
    end
    
    #2. create sql 
    deleteQuery = "DELETE FROM 担当者別画面マスタ "
    deleteQuery += " WHERE 担当者コード = '" + @tantocode + "'";    
    deleteQuery += " AND 画面プログラム = '" + @gamenprog + "'";
    
    #3. exec sql and return
    respond_to do |format|    
      begin
        result = @connection.ExecuteQuery(deleteQuery);
        # redirect_to :controller=>'seisankankatukoujoumasuta', :action => 'index'
        if result == "0"
          format.html { redirect_to :controller => "tantosyabetugamenmasuta", :action => "index", notice: '削除に成功しました。'}
          format.json { head :no_content }
        else
          format.html { redirect_to :controller => "tantosyabetugamenmasuta", :action => "index", notice: '削除に失敗しました。'}
          format.json { head :no_content }
        end
      rescue
        format.html { redirect_to :controller => "tantosyabetugamenmasuta", :action => "index", notice: '削除に失敗しました。'}
        format.json { head :no_content }
      ensure 
      end
    end
  end

  # Functioｎ
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
  
  def GetGamenListWithTanto(tantocode)
    # 1. create connection
    connection = Connection.new();
    # get tantogroup from tantoCode
    # get kihon date
    honjitudate = connection.GetHonjitu()
    tantocode = Publicfunction.pf_nvl_string(tantocode, "")
    tantoRec = Publicfunction.pf_get_tanto_single(connection, tantocode, honjitudate )
    Rails.logger.info 'dvquan.GetGamenListWithTanto.honjitudate: ' + honjitudate.to_s
    if !tantoRec.nil? then
      tantogroupcode = Publicfunction.pf_nvl_string(tantoRec["担当グループコード"], "")
      Rails.logger.info 'dvquan.GetGamenListWithTanto.tantogroupcode: ' + tantogroupcode
    else
      tantogroupcode = ""
    end
    
    # 2. query
    where = " where  exists  ( select  1 "
    where += " from    担当グループ別画面マスタ  b"
    where += " where   b.画面プログラム   = a.画面プログラム "
    where += " and   b.担当グループコード = '"  + tantogroupcode + "'  "
    where += " )"
    #Tantogroupmasuta
    query = "SELECT  a.画面プログラム"
    query +="       , a.画面プログラム || ' : ' || a.画面名称 AS 画面名称"
    query +="       , a.更新担当者コード"
    query +="      , a.更新プログラム"
    query +="      , a.更新日時"
    query +="      , a.入力日時 "
    query +="   FROM 画面マスタ a";
    query += where
    # sort
    query +=" ORDER BY a.画面プログラム"; 
    models = Array.new;    
    models1 = Hash.new;
    models1 = connection.ExecuteSelectQuery(query);
    index = 0;
    models1.each do |hashValue|
      record = Gamenmasuta.new("");
      record.puts(hashValue);
      models[index] = record;
      index = index + 1;
    end
    
    return models    
  end
end