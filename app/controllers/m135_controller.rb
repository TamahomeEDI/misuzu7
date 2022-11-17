#!/bin/env ruby
# encoding: utf-8
#require 'will_paginate/array' 
require 'csv' # csvファイルを出力。
require 'iconv'
require 'controllerModel/m135controllerModel.rb'

class M135Controller < BaseController
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
    #@models1 = Seisankankatukoujoumasuta.index(@connection).paginate(:page => params[:page], :per_page => 2);
      @models1 = M135controllerModel.findAll();

    end  
    # End Add 
    format = params[:format]
      if format == "csv"
        @models1 = M135controllerModel.findAll();
      end        
    index = 0;
    @models1.each do |hashValue|
      record = Seisankankatukoujoumasuta.new("");
      record.puts(hashValue);
      @models[index] = record;
      index = index + 1;
      end
      
  #@models = @models.paginate(:page => params[:page], :per_page => 5)


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
      line += ',"' + model.更新日時.strftime("%Y/%m/%d %H:%M:%S") + '"'
      line += ',"' + model.入力日時.strftime("%Y/%m/%d %H:%M:%S") + '"'
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
  

  
def create
  
  @DELETECODES=params["deleteCode"]
  @FLAGS=params["flag"]
  @SEISANCODE=params["SEISANCODE"]
  @SEISANMEISYOU=params["SEISANMEISYOU"]
  @JISHASOTOKUBUN=params["JISHASOTOKUBUN"]
  tantoCode = session["tantocode"];
  if tantoCode.nil?
    tantoCode = " "
  end
  @KOUSINTANTOUSYACODE=tantoCode#更新担当者コード  
  @GETPROGID="m135"#更新プログラム 
  #更新日時, 入力日時 sysdateString = "TO_DATE('" + sysdate + "','YYYY/MM/DD HH24:MI:SS')";
  
  @arrRecord_ADDNEW=Array.new
  @arrRecord_UPDATE=Array.new
  indexAdd=0
  indexUpdate=0
  @countArray=@FLAGS.size
  for i in 1..@countArray-1
    @arrColums=Array.new
    @arrColums[0]=@SEISANCODE[i]
    @arrColums[1]=@SEISANMEISYOU[i]
    @arrColums[2]=@JISHASOTOKUBUN[i]
    @arrColums[3]=@KOUSINTANTOUSYACODE
    @arrColums[4]=@GETPROGID
    
    #追加の場合
    if(@FLAGS[i]=="ADDNEW") then
      @arrRecord_ADDNEW[indexAdd]=@arrColums
      indexAdd=indexAdd+1
    end
   
    #更新の場合
    if(@FLAGS[i]=="UPDATE") then
      @arrRecord_UPDATE[indexUpdate]=@arrColums
      indexUpdate=indexUpdate+1
    end
    
  end
  
  #削除の場合
  @arrCondition=Array.new
  @arrRecord_DELETE=Array.new
  @arr_csv_cut=Publicfunction.pf_csv_cut(@DELETECODES)
  @countArray=@arr_csv_cut.size
  for i in 1..@countArray-1
    @arrCondition=Publicfunction.pf_format_cut(@arr_csv_cut[i],";")
    @arrRecord_DELETE[i-1]=@arrCondition
  end
  
  M135controllerModel.updateForm(@arrRecord_DELETE,@arrRecord_UPDATE,@arrRecord_ADDNEW)
  
  #logger.info "params['TANTOUSYACODE'] :" + @DELETECODE
  redirect_to :controller=>'m135', :action => 'index'
end
end
