#!/bin/env ruby
# encoding: utf-8
require 'csv' # csvファイルを出力。
require 'iconv'
require 'tantogroupmasuta_model.rb'
class TantogroupmasutaController < BaseController
  #================================================================
  #   名　称    TantogroupmasutaController
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
    return "mb_002"
  end
  def self.GetPageTitle(tantoname, user, dbserver)
    return TantogroupmasutaController.GetProgId + " 担当グループマスタ  (" + TantogroupmasutaController.GetVersion + ")-[" + tantoname + "]" + "- [" + user + "@" + dbserver + "]";
  end
  
  def index
    @connection = Connection.new();
    tantoname = session["tantoname"]
    if tantoname.nil?
      tantoname = "***"
    end
    
    # @pageTitle = "mb_002 担当グループマスタ  (" + TantogroupmasutaController.GetVersion + ")-[" + tantoname + "]" + "- [" + @connection.DatabaseUserName + "@" + @connection.DatabaseServer + "]";
    @pageTitle = TantogroupmasutaController.GetPageTitle(tantoname, @connection.DatabaseUserName, @connection.DatabaseServer)
    query = "SELECT  担当グループコード"
    query +="       , 担当グループ名称"
    query +="       , 更新担当者コード"
    query +="      , 更新プログラム"
    query +="      , 更新日時"
    query +="      , 入力日時 "
    query +="   FROM 担当グループマスタ";
    # sort
    query +=" ORDER BY 担当グループコード"; 
    @models = Array.new;    
    @models1 = Hash.new;
    @models1 = @connection.ExecuteSelectQuery(query);
    index = 0;
    @models1.each do |hashValue|
      record = Tantogroupmasuta.new("");
      record.puts(hashValue);
      @models[index] = record;
      index = index + 1;
    end

    @message = params[:notice];
    # begin using csv
    header = '担当グループコード, 担当グループ名称, 更新担当者コード, 更新プログラム, 更新日時, 入力日時'
    csv_string = header    
    @models.each do |model|
      if model.更新担当者コード.nil? then
        model.更新担当者コード = ""
      end
      
      if model.更新プログラム.nil? then
        model.更新プログラム = ""
      end
      
      line = '"' + model.担当グループコード + '"'
      line += ',"' + model.担当グループ名称 + '"'
      line += ',"' + model.更新担当者コード + '"'
      line += ',"' + model.更新プログラム + '"'
      if !model.更新日時.nil? then
        # Del by nmhuyen 12/10/2012 bug 011
        #line += ',"' + model.更新日時.to_formatted_s(:default) + '"'
        #End Del
        # Add by nmhuyen 12/10/2012 bug 011
        line += ',"' + model.更新日時.strftime("%Y/%m/%d %H:%M:%S") + '"'
        # End Add
      else
        line += ',"' + ' "'
      end
      
      if !model.入力日時.nil? then
        # Del by nmhuyen 12/10/2012 bug 011
        #line += ',"' + model.入力日時.to_formatted_s(:default) + '"'
        #End Del
        # Add by nmhuyen 12/10/2012 bug 011
        line += ',"' + model.入力日時.strftime("%Y/%m/%d %H:%M:%S") + '"'
        # End Add
      else
        line += ',"' + '"'
      end
      csv_string += "\r\n" + line;
    end
    # csv_string = lines
    # end using csv
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @models }
      # format.csv { send_data :csv => @models.to_csv(@models)}
      # format.csv { render :csv => @models}
      #Delete by bdlong 5/10/2012
      #format.csv { send_data(Iconv.conv('shift-jis', 'utf-8', csv_string), :filename => "担当グループマスタ.csv", :type => "text/csv",  :charset => "utf-8") }
      # End Delete
       #ADD by bdlong 5/10/2012
      @fileName=Iconv.conv('shift-jis', 'utf-8', "担当グループマスタ.csv");
      format.csv { send_data(Iconv.conv('shift-jis', 'utf-8', csv_string), :filename => @fileName, :type => "text/csv",  :charset => "utf-8") }
      #END ADD
      
    end
  end
  
  def create
    @connection = Connection.new();
    @model = Tantogroupmasuta.new("");
    sysdate = @connection.GetSystemDate;
    sysdateString = "TO_DATE('" + sysdate + "','YYYY/MM/DD HH24:MI:SS')";
    tantoCode = session["tantocode"];
    if tantoCode.nil?
      tantoCode = " "
    end
    
    # フォームのデータを取ります。params[フォーム名刺]
    param = params[:input_form]
    @model.担当グループコード = param[:担当グループコード];
    @model.担当グループ名称 = param[:担当グループ名称];
    @model.更新担当者コード = tantoCode;
    @model.更新プログラム = TantogroupmasutaController.GetProgId;
    insertQuery = "INSERT INTO 担当グループマスタ(担当グループコード, 担当グループ名称, 更新担当者コード, 更新プログラム, 更新日時, 入力日時)"
    insertQuery += "VALUES( ";
    insertQuery += " " + ActiveRecord::Base.sanitize(@model.担当グループコード) + "";
    insertQuery += ", " + ActiveRecord::Base.sanitize(@model.担当グループ名称) + "";
    insertQuery += ", '" + @model.更新担当者コード + "'";
    insertQuery += ", '" + @model.更新プログラム + "'";
    insertQuery += ", " + sysdateString;
    insertQuery += ", " + sysdateString;    
    insertQuery += " )";
  
    respond_to do |format|
        result = @connection.ExecuteQuery(insertQuery);
        @saveMessage = "RecordUpdated!";
        # redirect_to :controller=>'seisankojomasuta', :action => 'index'
        logger.info 'dvquan.query: seisan.create ' + result;
        if result == "0"
          @model.message = "追加に成功しまた。";
          format.html { redirect_to :controller => "tantogroupmasuta", :action => "show", :id => @model.担当グループコード, notice: '追加に成功しまた.' };
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
    @connection = Connection.new();
    tantoname = session["tantoname"]
    if tantoname.nil?
      tantoname = "  "
    end
    
    # page title 
    @pageTitle = TantogroupmasutaController.GetPageTitle(tantoname, @connection.DatabaseUserName, @connection.DatabaseServer)
    mode = params[:mode]
    @model = Tantogroupmasuta.new("");
    if mode == "1" then
      # copy button
      @id = params[:id];
      if !@id.nil? then
        query = "SELECT  担当グループコード"
        query +="       , 担当グループ名称"
        query +="       , 更新担当者コード"
        query +="      , 更新プログラム"
        query +="      , 更新日時"
        query +="      , 入力日時 "
        query +="   FROM 担当グループマスタ";
        query +="   WHERE 担当グループコード='" + @id + "'";
        
        records = @connection.ExecuteSelectQuery(query)
        @model = Tantogroupmasuta.new("1");    
        
        if !records.nil?
          @model.puts(records[0]);
        end 
      end
    end
    
    @model.action_name = "new"
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @model }
    end
  end
  
  def edit
    @connection = Connection.new();
    tantoname = session["tantoname"]
    if tantoname.nil?
      tantoname = "  "
    end
    
    @pageTitle = TantogroupmasutaController.GetPageTitle(tantoname, @connection.DatabaseUserName, @connection.DatabaseServer)
    @id = params[:id];
    query = "SELECT  担当グループコード"
    query +="       , 担当グループ名称"
    query +="       , 更新担当者コード"
    query +="      , 更新プログラム"
    query +="      , 更新日時"
    query +="      , 入力日時 "
    query +="   FROM 担当グループマスタ";
    query +="   WHERE 担当グループコード='" + @id + "'";
        
    records = @connection.ExecuteSelectQuery(query)
    @model = Tantogroupmasuta.new("1");    
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
    @pageTitle = TantogroupmasutaController.GetPageTitle(tantoname, @connection.DatabaseUserName, @connection.DatabaseServer)
    @id = params[:id];
    query = "SELECT  担当グループコード"
    query +="       , 担当グループ名称"
    query +="       , 更新担当者コード"
    query +="      , 更新プログラム"
    query +="      , 更新日時"
    query +="      , 入力日時 "
    query +="   FROM 担当グループマスタ";
    query +="   WHERE 担当グループコード='" + @id + "'";
        
    records = @connection.ExecuteSelectQuery(query)
    @model = Tantogroupmasuta.new("1");
    #@kojomasuta.生産管轄工場コード= "DV007";
    if !records.nil?
      @model.puts(records[0]);
    end
    
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
    @model.担当グループ名称 = param[:担当グループ名称];
    updateQuery = "UPDATE 担当グループマスタ "
    updateQuery += " SET 担当グループ名称 = " + ActiveRecord::Base.sanitize(@model.担当グループ名称) + "";
    updateQuery += ", 更新担当者コード = '" + tantoCode + "'";
    updateQuery += ", 更新日時 = " + sysdateString; 
    updateQuery += " WHERE 担当グループマスタ.担当グループコード = '" + @model.担当グループコード + "'";    
    respond_to do |format|
      begin
          result = @connection.ExecuteQuery(updateQuery);
          # redirect_to :controller=>'seisankankatukoujoumasuta', :action => 'show'
          if result == "0"
            format.html { redirect_to :controller => "tantogroupmasuta", :action => "show", :id => @model.担当グループコード, notice: '更新に成功しまた.' };
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

  def show
    @connection = Connection.new();
    tantoname = session["tantoname"]
    if tantoname.nil?
      tantoname = "*"
    end
    
    @pageTitle = TantogroupmasutaController.GetPageTitle(tantoname, @connection.DatabaseUserName, @connection.DatabaseServer)
    @id = params[:id];
    query = "SELECT  担当グループコード"
    query +="       , 担当グループ名称"
    query +="       , 更新担当者コード"
    query +="      , 更新プログラム"
    query +="      , 更新日時"
    query +="      , 入力日時 "
    query +="   FROM 担当グループマスタ";
    query +="   WHERE 担当グループコード='" + @id + "'";
    
    records = @connection.ExecuteSelectQuery(query)
    @model = Tantogroupmasuta.new("1");
    if !records.nil? && !records[0].nil?
      @model.puts(records[0]);
    end
    
    @model.message = params[:notice];
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @model }
    end
  end
  
  def destroy
    @connection = Connection.new();
    @id = params[:id]    
    deleteQuery = "DELETE FROM 担当グループマスタ"
    deleteQuery += " WHERE 担当グループコード = '" + @id + "'";
    respond_to do |format|    
      begin
        result = @connection.ExecuteQuery(deleteQuery);
        # redirect_to :controller=>'seisankankatukoujoumasuta', :action => 'index'
        if result == "0"
          format.html { redirect_to :controller => "tantogroupmasuta", :action => "index", notice: '削除に成功しました。'}
          format.json { head :no_content }
        else
          format.html { redirect_to :controller => "tantogroupmasuta", :action => "index", notice: '削除に失敗しました。'}
          format.json { head :no_content }
        end
      rescue
        format.html { redirect_to :controller => "tantogroupmasuta", :action => "index", notice: '削除に失敗しました。'}
        format.json { head :no_content }
      ensure 
      end
    end
  end
end