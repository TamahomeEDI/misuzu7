#!/bin/env ruby
# encoding: utf-8
require 'csv' # csvファイルを出力。
require 'iconv'
require 'seisankankatukoujoumasuta_model.rb'
class SeisankankatukoujoumasutaController < BaseController
  #================================================================
  #   名　称    SeisankankatukoujoumasutaController
  #   説　明    アクションを抑制しまた。
  #   補　足
  #   引　数 なし
  #   戻　値
  # (history)
  #   date         ver        name                      comments
  #  -------     -----      ----------------          -----------------
  #  2012.08.08  1.00.00     quandv118@gmail.com       新規作成
  #=================================================================
  def self.GetVersion
    return "ver.1.00.00";
  end
  
  def index
    @connection = Connection.new();
    tantoname = session["tantoname"]
    if tantoname.nil?
      tantoname = "***"
    end
    @pageTitle = "m135 生産管轄工場マスタ  (" + SeisankankatukoujoumasutaController.GetVersion + ")-[" + tantoname + "]" + "- [" + @connection.DatabaseUserName + "@" + @connection.DatabaseServer + "]";
    @models = Array.new;    
    @models1 = Hash.new;
    logger.info 'nmhuyen.cache ' + Rails.cache.exist?('seisankankatukoujourisuto').to_s 
    # Add by HuyenNM 27/9/2012 for cache data    
    if fragment_exist?('seisankankatukoujourisuto', nil) == false
    @models1 = Seisankankatukoujoumasuta.index(@connection);
    end  
    # End Add 
    format = params[:format]
      if format == "csv"
        @models1 = Seisankankatukoujoumasuta.index(@connection);
      end        
    index = 0;
    @models1.each do |hashValue|
      record = Seisankankatukoujoumasuta.new("");
      record.puts(hashValue);
      @models[index] = record;
      index = index + 1;
      end
   

    @message = params[:notice];
    # begin using csv
    header = '生産管轄工場コード, 生産管轄工場名称, 自社外注区分, 更新担当者コード, 更新プログラム, 更新日時, 入力日時'
    csv_string = header   
   logger.info 'nmhuyen.@models.length ' + @models.length.to_s
    @models.each do |model|
      line = '"' + model.生産管轄工場コード + '"'
      line += ',"' + model.生産管轄工場名称 + '"'
      line += ',"' + model.自社外注区分 + '"'
      line += ',"' + model.更新担当者コード + '"'
      line += ',"' + model.更新プログラム + '"'
      line += ',"' + model.更新日時.to_formatted_s(:default) + '"'
      line += ',"' + model.入力日時.to_formatted_s(:default) + '"'
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
      #format.csv { send_data(Iconv.conv('shift-jis', 'utf-8', csv_string), :filename => "生産管轄工場マスタ.csv", :type => "text/csv",  :charset => "utf-8") }
      # End Delete
      #ADD by bdlong 5/10/2012 
      @fileName=Iconv.conv('shift-jis', 'utf-8', "生産管轄工場マスタ.csv");  
      format.csv { send_data(Iconv.conv('shift-jis//IGNORE', 'utf-8', csv_string), :filename => @fileName, :type => "text/csv",  :charset => "shift-jis") }
      #End Add
    end
  end

  def create
    @connection = Connection.new();
    @model = Seisankankatukoujoumasuta.new("");
    tantoCode = session["tantocode"];
    if tantoCode.nil?
      tantoCode = " "
    end
    
    # フォームのデータを取ります。params[フォーム名刺]
    param = params[:input_form]
    mode = params[:mode]
    @model.生産管轄工場コード = param[:生産管轄工場コード];
    @model.生産管轄工場名称 = param[:生産管轄工場名称];
    @model.自社外注区分 = param[:自社外注区分];
    @model.更新担当者コード = tantoCode;
    @model.更新プログラム = "m135";
    respond_to do |format|       
        result = Seisankankatukoujoumasuta.create(@connection, mode, @model);
        @saveMessage = "RecordUpdated!";
        # redirect_to :controller=>'seisankojomasuta', :action => 'index'
        logger.info 'dvquan.query: seisan.create ' + result;
        if result == "0"
          # Add by HuyenNM 27/9/2012 for cache data
          expire_fragment('seisankankatukoujourisuto');         
          #End Add
          @model.message = "追加に成功しまた。";
          format.html { redirect_to :controller => "seisankankatukoujoumasuta", :action => "show", :id => @model.生産管轄工場コード, notice: '追加に成功しまた.' };
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
    @pageTitle = "m135 生産管轄工場マスタ  (" + SeisankankatukoujoumasutaController.GetVersion + ")-[" + tantoname + "]" + "- [" + @connection.DatabaseUserName + "@" + @connection.DatabaseServer + "]";
    mode = params[:mode]
    @model = Seisankankatukoujoumasuta.new("");
    if mode == "1" then
      @id = params[:id];
      if !@id.nil? then
        records = Seisankankatukoujoumasuta.insert(@connection,@id);
        @model = Seisankankatukoujoumasuta.new("1");    
        #@kojomasuta.生産管轄工場コード= "DV007";
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
    @pageTitle = "m135 生産管轄工場マスタ  (" + SeisankankatukoujoumasutaController.GetVersion + ")-[" + tantoname + "]" + "- [" + @connection.DatabaseUserName + "@" + @connection.DatabaseServer + "]";
    @id = params[:id];
    records = Seisankankatukoujoumasuta.edit(@connection,@id);    
    @model = Seisankankatukoujoumasuta.new("1");    
    #@kojomasuta.生産管轄工場コード= "DV007";
    if !records.nil?
      @model.puts(records[0]);
    end 
  end

def update
  @connection = Connection.new();
  tantoname = session["tantoname"]
  if tantoname.nil?
    tantoname = "***"
  end
  @pageTitle = "m135 生産管轄工場マスタ  (" + SeisankankatukoujoumasutaController.GetVersion + ")-[" + tantoname + "]" + "- [" + @connection.DatabaseUserName + "@" + @connection.DatabaseServer + "]";
  @id = params[:id];
  @model = Seisankankatukoujoumasuta.new("1")
  # フォームのデータを取ります。params[フォーム名刺]
  param = params[:input_form]
  tantoCode = session["tantocode"];  
  # form
  @model.生産管轄工場名称 = param[:生産管轄工場名称];
  @model.自社外注区分 = param[:自社外注区分]; 
  respond_to do |format|   
    begin
      @model.生産管轄工場コード = param[:生産管轄工場コード]
      #  updateQuery = "UPDATE 生産管轄工場マスタ "
      result = Seisankankatukoujoumasuta.update(@connection,@id, param, tantoCode);         
        # redirect_to :controller=>'seisankankatukoujoumasuta', :action => 'show'
        if result == "0"
          # Add by HuyenNM 27/9/2012 for cache data
          expire_fragment('seisankankatukoujourisuto');
          #End Add
          format.html { redirect_to :controller => "seisankankatukoujoumasuta", :action => "show", :id => @id, notice: '更新に成功しまた.' };
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
    
    @pageTitle = "m135 生産管轄工場マスタ  (" + SeisankankatukoujoumasutaController.GetVersion + ")-[" + tantoname + "]" + "- [" + @connection.DatabaseUserName + "@" + @connection.DatabaseServer + "]";
    @id = params[:id];
    records = Seisankankatukoujoumasuta.show(@connection, @id);
    @model = Seisankankatukoujoumasuta.new("1");
    if !records.nil?
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
    respond_to do |format|    
      begin
        result = Seisankankatukoujoumasuta.destroy(@connection, @id);       
        # redirect_to :controller=>'seisankankatukoujoumasuta', :action => 'index'
        if result == "0"
          # Add by HuyenNM 27/9/2012 for cache data
          expire_fragment('seisankankatukoujourisuto');
          #End Add         
          format.html { redirect_to :controller => "seisankankatukoujoumasuta", :action => "index", notice: '削除に成功しました。'}
          format.json { head :no_content }
        else
          format.html { redirect_to :controller => "seisankankatukoujoumasuta", :action => "index", notice: '削除に失敗しました。'}
          format.json { head :no_content }
        end
      rescue
        format.html { redirect_to :controller => "seisankankatukoujoumasuta", :action => "index", notice: '削除に失敗しました。'}
        format.json { head :no_content }
      ensure 
      end
    end
  end
  
  # データ出力
  def export
    @connection = Connection.new();
    tantoname = session["tantoname"]
    if tantoname.nil?
      tantoname = "***"
    end
    @pageTitle = "m135 生産管轄工場マスタ  (" + SeisankankatukoujoumasutaController.GetVersion + ")-[" + tantoname + "]" + "- [" + @connection.DatabaseUserName + "@" + @connection.DatabaseServer + "]";
#    query = "SELECT  生産管轄工場コード"
#    query +="       , 生産管轄工場名称"
#    query +="       , 自社外注区分"
#    query +="      , 更新担当者コード"
#    query +="       , 更新プログラム"
#    query +="      , 更新日時"
#    query +="      , 入力日時 "
#    query +="   FROM 生産管轄工場マスタ ORDER BY 生産管轄工場コード";    
    @models = Hash.new;
    @models = Seisankankatukoujoumasuta.export(@connection);
    @message = params[:notice];
    respond_to do |format|
      format.html # index.html.erb
      format.csv # export.csv.erb
    end   
  end
end
