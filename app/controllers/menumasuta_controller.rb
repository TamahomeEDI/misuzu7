#!/bin/env ruby
# encoding: utf-8
require 'csv' # csvファイルを出力。
require 'iconv'
require 'menumasuta_model.rb'
require 'tantogroupmasuta_model.rb'
require 'tantogroupbetugamenmasuta_model.rb'
require 'date'
class MenumasutaController < BaseController
    #================================================================
    #   名　称    MenumasutaController
    #   説　明    アクションを抑制しまた。
    #   補　足
    #   引　数 なし
    #   戻　値
    # (history)
    #   date         ver        name                      comments
    #  -------     -----      ----------------          -----------------
    #  2012.09.12  1.00.00     quandv118@gmail.com       新規作成
    #=================================================================
    def self.GetVersion
      return "ver.1.00.00";
    end
    
    def self.GetProgId
      return "mb_003"
    end
    
    def self.GetPageTitle(tantoname, user, dbserver)
      return MenumasutaController.GetProgId + " メニューマスタ  (" + MenumasutaController.GetVersion + ")-[" + tantoname + "]" + "- [" + user + "@" + dbserver + "]";
    end
    
  def index
    # Action Index
    tantoname = session["tantoname"]
    if tantoname.nil?
      tantoname = "";
    end
    @connection = Connection.new();
    @pageTitle = MenumasutaController.GetPageTitle(tantoname, @connection.DatabaseUserName, @connection.DatabaseServer)
    
    # get term id from sequence .
    termId = session["termid"]
    #get tantogroupcode
    tantogroupcode = Publicfunction.pf_nvl_string(params["tantogroupcode"], "")
    tantomenufocus = ""

    #メニューリストを作成する。
    query = "CALL P_MAIN001(" + termId.to_s + ", '" + tantogroupcode + "','' )";
    result = @connection.ExecuteQuery(query);

    if(result == "0") then
      #メニューリストを取得する。
      selectQuery = "SELECT a.端末番号"
      selectQuery += ", a.表示ラベル"
      selectQuery += ", a.レベル"
      selectQuery += ", a.ツリー順序"
      selectQuery += ", a.メニューコード"
      selectQuery += ", a.フォーカスフラグ"
      selectQuery += ", a.メニュー名称"
      selectQuery += ", 0 AS  ハンドル"

      selectQuery += " FROM  MAIN001_テンプ a "
      selectQuery += " WHERE a.端末番号  = " + (Integer(termId)).to_s()
      selectQuery += " ORDER BY  a.ツリー順序"
      selectQuery += ", a.表示ラベル"

      @models = Array.new;    
      @models1 = Hash.new;
      @models1 = @connection.ExecuteSelectQuery(selectQuery);
      index = 0
      @models1.each do |hashValue|
        record = Menu001_temp.new(1);
        record.puts(hashValue);
        @models[index] = record;
        index = index + 1;
      end
      
      @htmlString = wf_CreateTree(@models, tantomenufocus, tantogroupcode)
      Rails.logger.info 'dvquan.IndexAction.HTML: ' + @htmlString
      
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
      selectQuery += " AND  a.親メニューコード = ' '"
      selectQuery += " ORDER BY  a.親メニューコード"
      selectQuery += ", a.表示順序"      
      selectQuery += ", a.メニューコード"
      @menumasutaModels = Array.new;
      @models1 = Hash.new;
      @models1 = @connection.ExecuteSelectQuery(selectQuery);
      index = 0
      @models1.each do |hashValue|
        record = Menumasuta.new("");
        record.puts(hashValue);
        @menumasutaModels[index] = record;
        index = index + 1;
      end
      
      #**** get data for 担当グループ別画面マスタ
      selectQuery = "SELECT a.担当グループコード"
      selectQuery += ", a.メニューコード"
      selectQuery += ", a.画面プログラム"
      selectQuery += ", b.画面名称"
      selectQuery += ", a.権限区分"
      selectQuery += ", a.表示順序"
      selectQuery += ", a.ボタン名称"      
      selectQuery += ", a.更新担当者コード"
      selectQuery += ", a.更新プログラム"
      selectQuery += ", a.更新日時"
      selectQuery += ", a.入力日時"
      selectQuery += " FROM  担当グループ別画面マスタ a "
      selectQuery += " ,  画面マスタ b "
      selectQuery += " WHERE a.画面プログラム = b.画面プログラム(+)" 
      selectQuery += " AND a.担当グループコード  = '" + tantogroupcode + "'"
      selectQuery += " AND a.メニューコード  = '  '"
      # select with menu is child of root.
      selectQuery += " ORDER BY  a.メニューコード"
      selectQuery += ", a.表示順序"      
      selectQuery += ", a.画面プログラム"
      @tantogroupbetumodels = Array.new;
      @models1 = Hash.new;
      @models1 = @connection.ExecuteSelectQuery(selectQuery);
      index = 0
      @models1.each do |hashValue|
        record = Tantogroupbetugamenmasuta.new("");
        record.puts(hashValue);
        @tantogroupbetumodels[index] = record;
        index = index + 1;
      end
  
      # get data for parent menu and link
      # get parent menu information to show header
      record = wf_GetParentMenuInfor(@connection, termId, " ")
      @parentmenucode = " "
      @parentmenuname = ""
      @tantogroupcode = tantogroupcode
      if !record.nil? && !record.メニュー名称.nil? then
        @parentmenuname = Publicfunction.pf_nvl_string(record.メニュー名称, "")
      end
      # get select list tanto 
      @tantoGroupList = Publicfunction.pf_GetTantoGroupList(@connection)
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @models }
      end
    end
  end
  
  def create
    @connection = Connection.new();
    @model = Menumasuta.new("");
    sysdate = @connection.GetSystemDate;
    sysdateString = "TO_DATE('" + sysdate + "','YYYY/MM/DD HH24:MI:SS')";
    tantoCode = session["tantocode"];
    if tantoCode.nil?
      tantoCode = " "
    end
  
    # フォームのデータを取ります。params[フォーム名刺]
    param = params[:input_form]
    # get param screen mode
    @screen =  Publicfunction.pf_nvl_string(param[:screen], "0");
    if @screen == "1" then
      @model = Menumasuta.new("");
      #MenuMasuta
      @model.担当グループコード = Publicfunction.pf_nvl_string(param[:担当グループコード], "");
      @model.メニューコード = Publicfunction.pf_nvl_string(param[:メニューコード], "");
      @model.メニュー名称 = Publicfunction.pf_nvl_string(param[:メニュー名称], "-1");
      @model.親メニューコード = " "
      orderstring = Publicfunction.pf_nvl_string(param[:表示順序], "1");
      orderNum = 1.00
      begin
        orderNum = orderstring.to_f
      rescue
        orderNum = 1.00
      end
      @model.表示順序 = orderNum;
      @model.更新担当者コード = tantoCode;
      @model.更新プログラム = MenumasutaController.GetProgId;
      insertQuery = "INSERT INTO メニューマスタ(担当グループコード, メニューコード, メニュー名称, 親メニューコード, 表示順序, 更新担当者コード, 更新プログラム, 更新日時, 入力日時)"
      insertQuery += "VALUES( ";
      insertQuery += " " + ActiveRecord::Base.sanitize(@model.担当グループコード) + "";
      insertQuery += ", " + ActiveRecord::Base.sanitize(@model.メニューコード) + "";
      insertQuery += ", " + ActiveRecord::Base.sanitize(@model.メニュー名称) + "";
      insertQuery += ", " + ActiveRecord::Base.sanitize(@model.親メニューコード) + "";
      insertQuery += ", " + @model.表示順序.to_s + "";
      insertQuery += ", '" + @model.更新担当者コード + "'";
      insertQuery += ", '" + @model.更新プログラム + "'";
      insertQuery += ", " + sysdateString;
      insertQuery += ", " + sysdateString;    
      insertQuery += " )";
    else
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++      
      #TantogroupbetuGamen
      @model = Tantogroupbetugamenmasuta.new("");
      #MenuMasuta
      @model.担当グループコード = Publicfunction.pf_nvl_string(param[:担当グループコード], " ");
      @model.メニューコード = Publicfunction.pf_nvl_string(param[:メニューコード], " ");
      @model.画面プログラム = Publicfunction.pf_nvl_string(param[:画面プログラム], " ");
      @model.権限区分 = Publicfunction.pf_nvl_string(param[:権限区分], " ");
      @model.ボタン名称 = Publicfunction.pf_nvl_string(param[:ボタン名称], " ");
      orderstring = Publicfunction.pf_nvl_string(param[:表示順序], "1");
      Rails.logger.info "INIT: 2: tantogroupcode: "   + @model.担当グループコード + " : @parentmenucode" + @model.メニューコード
      orderNum = 1.00
      begin
        orderNum = orderstring.to_f
      rescue
        orderNum = 1.00
      end
      @model.表示順序 = orderNum;
      @model.更新担当者コード = tantoCode;
      @model.更新プログラム = MenumasutaController.GetProgId;
      insertQuery = "INSERT INTO 担当グループ別画面マスタ(担当グループコード, メニューコード, 画面プログラム, 権限区分, 表示順序, ボタン名称, 更新担当者コード, 更新プログラム, 更新日時, 入力日時)"
      insertQuery += "VALUES( ";
      insertQuery += " " + ActiveRecord::Base.sanitize(@model.担当グループコード) + "";
      insertQuery += ", " + ActiveRecord::Base.sanitize(@model.メニューコード) + "";
      insertQuery += ", " + ActiveRecord::Base.sanitize(@model.画面プログラム) + "";
      insertQuery += ", " + ActiveRecord::Base.sanitize(@model.権限区分) + "";
      insertQuery += ", " + @model.表示順序.to_s + "";
      insertQuery += ", " + ActiveRecord::Base.sanitize(@model.ボタン名称) + "";
      insertQuery += ", '" + @model.更新担当者コード + "'";
      insertQuery += ", '" + @model.更新プログラム + "'";
      insertQuery += ", " + sysdateString;
      insertQuery += ", " + sysdateString;    
      insertQuery += " )";
      
      #Reference table
      @gamenList = GetGamenListWithTantogroup(@model.担当グループコード)
    end
  
    # references tables

    respond_to do |format|
        result = @connection.ExecuteQuery(insertQuery);
        @saveMessage = "RecordUpdated!";
        # redirect_to :controller=>'seisankojomasuta', :action => 'index'
        logger.info 'dvquan.query: tantosyabetugamenmasuta.result ' + result;
        if result == "0"
          @model.message = "追加に成功しまた。";
          idstring = @model.担当グループコード + "," + @model.メニューコード
          if @screen == "2" then
            idstring = @model.担当グループコード + "," + @model.画面プログラム
          end
          format.html { redirect_to :controller => "menumasuta", :action => "show", :id => idstring, screen: @screen, notice: '追加に成功しまた.' };
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
    # Get request
    mode = params[:mode]
    @screen = params[:screen]
    @tantogroupcode = Publicfunction.pf_nvl_string(params[:tantogroupcode], "")
    @menucode = Publicfunction.pf_nvl_string(params[:menucode], "")
    @model = Menumasuta.new("");
    
    if @screen == "1" then
      #Menumasuta create
      #メニューマスタに追加する。
      @model = Menumasuta.new("");
      # init new
      @model.担当グループコード = @tantogroupcode
      
      if mode == "1" then
        # copy button
        # get id from request.
        @id = Publicfunction.pf_nvl_string(params[:id], "");
        #process id (id contains 担当者コード and 画面プログラム)
        idList = Array.new
        idList = Publicfunction.pf_csv_cut(@id)
        @tantogroupcode = ""
        @menucode = ""
        if idList.size > 0 then
          @tantogroupcode = idList[0]
          logger.info "dvquan.@tantocode: " + @tantogroupcode
        end
        
        if idList.size > 1 then
            @menucode = idList[1]
            logger.info "dvquan.gamenprog: " + @menucode
        end
        
        if !@id.nil? then
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
          selectQuery += " WHERE a.担当グループコード  = '" + @tantogroupcode + "'"
          # select with menu is child of root.
          selectQuery += " AND  a.メニューコード = '" + @menucode + "'"
          records = @connection.ExecuteSelectQuery(selectQuery);
          @model = Menumasuta.new("");
          if !records.nil? && !records[0].nil?
            @model.puts(records[0]);
          end
        end
      end #mode
       # get new id
       menuId = Publicfunction.pf_GetMenuMasutaCode(@connection)
       if menuId.nil? then
         menuId = 0;
       end
       @model.メニューコード = menuId.to_s
        
      # references tables
    else
      #担当グループ別画面マスタ new
      #担当グループ別画面マスタに追加する。
      @model = Tantogroupbetugamenmasuta.new("");
      # using for add new
      @parentmenucode = Publicfunction.pf_nvl_string(params[:parentmenucode], "")
      # init new
      # @model.担当グループコード = @tantogroupcode
      
      if mode == "1" then
        # copy button
        # get id from request.
        @id = Publicfunction.pf_nvl_string(params[:id], "");
        #process id (id contains 担当者コード and 画面プログラム)
        idList = Array.new
        idList = Publicfunction.pf_csv_cut(@id)
        @tantogroupcode = ""
        @gamenprogcode = ""
        if idList.size > 0 then
          @tantogroupcode = idList[0]
          logger.info "dvquan.@tantocode: " + @tantogroupcode
        end
        
        if idList.size > 1 then
            @gamenprogcode = idList[1]
            logger.info "dvquan.gamenprog: " + @gamenprogcode
        end
        
        if !@id.nil? then
          #**** get data for 担当グループ別画面マスタ
          selectQuery = "SELECT a.担当グループコード"
          selectQuery += ", a.メニューコード"
          selectQuery += ", a.画面プログラム"
          selectQuery += ", b.画面名称"
          selectQuery += ", a.権限区分"
          selectQuery += ", a.表示順序"
          selectQuery += ", a.ボタン名称"      
          selectQuery += ", a.更新担当者コード"
          selectQuery += ", a.更新プログラム"
          selectQuery += ", a.更新日時"
          selectQuery += ", a.入力日時"
          selectQuery += ", c.メニュー名称"
          selectQuery += " FROM  担当グループ別画面マスタ a "
          selectQuery += " ,  画面マスタ b "
          selectQuery += " ,  メニューマスタ c "         
          selectQuery += " WHERE a.画面プログラム = b.画面プログラム(+)"
          selectQuery += " AND a.担当グループコード  = c.担当グループコード(+)" 
          selectQuery += " AND a.メニューコード  = c.メニューコード(+)"
          selectQuery += " AND a.担当グループコード  = '" + @tantogroupcode + "'"
          selectQuery += " AND a.画面プログラム  = '" + @gamenprogcode + "'"
           
          records = @connection.ExecuteSelectQuery(selectQuery);          
          @model = Tantogroupbetugamenmasuta.new("");
          if !records.nil? && !records[0].nil?
            @model.puts(records[0]);
          end
        end
      else
        #init record
        @model.担当グループコード = @tantogroupcode
        @model.メニューコード = @parentmenucode
        # Rails.logger.info "INIT: 2: tantogroupcode"   + @tantogroupcode + " : @parentmenucode" + @parentmenucode
      end #mode
      #Reference table
      @gamenList = GetGamenListWithTantogroup(@tantogroupcode)
    end
    
    
    # return client
    @model.action_name = "new"
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @model }
    end
  end

  def show
    @id = Publicfunction.pf_nvl_string(params[:id], "")
    @connection = Connection.new();
    # get term id from sequence .
    termId = session["termid"]
    # update_screen1
    case @id
      when "update_screen1"
        # ajax function
        # 1. Get param in ajax request
        @tantogroupcode = Publicfunction.pf_nvl_string(params[:ajax_tantogroup_code], "")
        menucode = Publicfunction.pf_nvl_string(params[:ajax_menu_code], "")
        if menucode == "00" then
          # root menu code = " "
          menucode = " " 
        end
        # get data
        record = wf_GetParentMenuInfor(@connection, termId, menucode)
        
        @parentmenucode = menucode
        @parentmenuname = ""
        if !record.nil? && !record.メニュー名称.nil? then
          @parentmenuname = Publicfunction.pf_nvl_string(record.メニュー名称, "")
        end
        
        logger.info 'dvquan.query: show update_screen1' + @tantogroupcode
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
        selectQuery += " WHERE a.担当グループコード  = '" + @tantogroupcode + "'"
        # select with menu is child of root.
        selectQuery += " AND  a.親メニューコード = '" + menucode + "'"
        selectQuery += " ORDER BY  a.親メニューコード"
        selectQuery += ", a.表示順序"      
        selectQuery += ", a.メニューコード"
        @menumasutaModels = Array.new;
        @models1 = Hash.new;
        @models1 = @connection.ExecuteSelectQuery(selectQuery);
        index = 0
        @models1.each do |hashValue|
          record = Menumasuta.new("");
          record.puts(hashValue);
          @menumasutaModels[index] = record;
          index = index + 1;
        end
        render :partial => "indexright1", :object => @menumasutaModels
      when "update_screen2"
        #担当グループ別画面マスタ
        # 1. Get param in ajax request
         @tantogroupcode = Publicfunction.pf_nvl_string(params[:ajax_tantogroup_code], "")
         menucode = Publicfunction.pf_nvl_string(params[:ajax_menu_code], "")
        if menucode == "00" then
          # root menu code = " "
          menucode = " " 
        end
         # get data
         record = wf_GetParentMenuInfor(@connection, termId, menucode)
         
         @parentmenucode = menucode
         @parentmenuname = ""
         if !record.nil? && !record.メニュー名称.nil? then
           @parentmenuname = Publicfunction.pf_nvl_string(record.メニュー名称, "")
         end
         #**** get data for 担当グループ別画面マスタ
          selectQuery = "SELECT a.担当グループコード"
          selectQuery += ", a.メニューコード"
          selectQuery += ", a.画面プログラム"
          selectQuery += ", b.画面名称"
          selectQuery += ", a.権限区分"
          selectQuery += ", a.表示順序"
          selectQuery += ", a.ボタン名称"      
          selectQuery += ", a.更新担当者コード"
          selectQuery += ", a.更新プログラム"
          selectQuery += ", a.更新日時"
          selectQuery += ", a.入力日時"
          selectQuery += " FROM  担当グループ別画面マスタ a "
          selectQuery += " ,  画面マスタ b "
          selectQuery += " WHERE a.画面プログラム = b.画面プログラム(+)" 
          selectQuery += " AND a.担当グループコード  = '" + @tantogroupcode + "'"
          selectQuery += " AND a.メニューコード  = '" + menucode + "'"
          # select with menu is child of root.
          selectQuery += " ORDER BY  a.メニューコード"
          selectQuery += ", a.表示順序"      
          selectQuery += ", a.画面プログラム"
          
          @tantogroupbetumodels = Array.new;
          @models1 = Hash.new;
          @models1 = @connection.ExecuteSelectQuery(selectQuery);
          index = 0
          
          # change hash value to object
          @models1.each do |hashValue|
            record = Tantogroupbetugamenmasuta.new("");
            record.puts(hashValue);
            @tantogroupbetumodels[index] = record;
            index = index + 1;
          end
          render :partial => "indexright2", :object => @tantogroupbetumodels
      when "exportcsv"
          @screen = Publicfunction.pf_nvl_string(params[:screen], "")
          @tantogroupcode = Publicfunction.pf_nvl_string(params[:tantogroupcode], "")
          @parentmenucode = Publicfunction.pf_nvl_string(params[:parentmenucode], " ")
          exportcsv(@screen, @tantogroupcode, @parentmenucode )
       #Add by nmhuyen 24/10/2012
        when "exportall"
          exportall()
       #End Add
    else
      #SHOW ACTION
      #GET PARAMS
      @screen = Publicfunction.pf_nvl_string(params[:screen], "")
      #process id (id contains 担当者コード and 画面プログラム)
      idList = Array.new
      idList = Publicfunction.pf_csv_cut(@id)
      @tantogroupcode = ""
      @menucode = ""
      @gamenprogcode = ""
      if idList.size > 0 then
        @tantogroupcode = idList[0]
        logger.info "dvquan.@tantogroupcode: " + @tantogroupcode
      end
      
      if idList.size > 1 then
          @menucode = idList[1]
          logger.info "dvquan.menucode: " + @menucode
          @gamenprogcode = idList[1]
      end 
             
      if @screen == "1" then
        # Menu masuta
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
        selectQuery += " WHERE a.担当グループコード  = '" + @tantogroupcode + "'"
        # select with menu is child of root.
        selectQuery += " AND  a.メニューコード = '" + @menucode + "'"
        menumasutaModels = Array.new;
        models1 = Hash.new;
        records = @connection.ExecuteSelectQuery(selectQuery);
        @model = Menumasuta.new("");
        if !records.nil? && !records[0].nil?
          @model.puts(records[0]);
        end
        
        @model.message = params[:notice];
        respond_to do |format|
          format.html # show.html.erb
          format.json { render json: @model }
        end
      else
        # 担当グループ別画面マスタ
        #**** get data for 担当グループ別画面マスタ
         selectQuery = "SELECT a.担当グループコード"
         selectQuery += ", a.メニューコード"
         selectQuery += ", a.画面プログラム"
         selectQuery += ", b.画面名称"
         selectQuery += ", a.権限区分"
         selectQuery += ", a.表示順序"
         selectQuery += ", a.ボタン名称"      
         selectQuery += ", a.更新担当者コード"
         selectQuery += ", a.更新プログラム"
         selectQuery += ", a.更新日時"
         selectQuery += ", a.入力日時"
         selectQuery += ", c.メニュー名称"
         selectQuery += " FROM  担当グループ別画面マスタ a "
         selectQuery += " ,  画面マスタ b "
         selectQuery += " ,  メニューマスタ c "         
         selectQuery += " WHERE a.画面プログラム = b.画面プログラム(+)"
         selectQuery += " AND a.担当グループコード  = c.担当グループコード(+)" 
         selectQuery += " AND a.メニューコード  = c.メニューコード(+)"
         selectQuery += " AND a.担当グループコード  = '" + @tantogroupcode + "'"
         selectQuery += " AND a.画面プログラム  = '" + @gamenprogcode + "'"
         
         records = @connection.ExecuteSelectQuery(selectQuery);
        
         @model = Tantogroupbetugamenmasuta.new("");
         if !records.nil? && !records[0].nil?
           @model.puts(records[0]);
           # if root メニューコード = "" then get parent name
           if Publicfunction.pf_nvl_string(@model.メニューコード, "") == "" && @model.メニュー名称.nil? then           
              termId = session["termid"]
              parentInfor = wf_GetParentMenuInfor(@connection, termId, " ")
              if !parentInfor.nil? && !parentInfor.メニュー名称.nil? then
                parentmenuname = Publicfunction.pf_nvl_string(parentInfor.メニュー名称, "")
              end
              @model.メニュー名称 = parentmenuname
           end
         end
         
         respond_to do |format|
           format.html # show.html.erb
           format.json { render json: @model }
         end
      end
    end
  end
  #Add by nmhuyen 24/10/2012
  def exportall
    @typeExport = params[:ajax_export_type]
    logger.info "@typeExport: " + @typeExport
    @tantogroupcode = Publicfunction.pf_nvl_string(params[:tantogroupcode], "")
     
    if @typeExport == "menu" 
    namefile=Iconv.conv('shift-jis', 'utf-8', "メニューマスタ.csv");
    cvs_string= exportMenu(@tantogroupcode);
    respond_to do |format|
      format.csv { send_data(Iconv.conv('shift-jis//IGNORE', 'utf-8', cvs_string), :filename => namefile, :type => "text/csv",  :charset => "shift-jis") }
    end
             
    elsif @typeExport == "group" 
    namefile=Iconv.conv('shift-jis', 'utf-8', "担当グループ別画面マスタ.csv");  
    cvs_string= exportGroup(@tantogroupcode);
      respond_to do |format|
        format.csv { send_data(Iconv.conv('shift-jis//IGNORE', 'utf-8', cvs_string), :filename => namefile, :type => "text/csv",  :charset => "shift-jis") }
    end

    
   elsif @typeExport == "all" 
    namefile1=Iconv.conv('shift-jis', 'utf-8', "メニューマスタ.csv");
    namefile2=Iconv.conv('shift-jis', 'utf-8', "担当グループ別画面マスタ.csv"); 
    cvs_string1= exportMenu(@tantogroupcode);
    cvs_string2= exportGroup(@tantogroupcode);
    
    
    respond_to do |format|
      format.csv { send_data(Iconv.conv('shift-jis//IGNORE', 'utf-8', cvs_string1), :filename => namefile1, :type => "text/csv",  :charset => "shift-jis") }
      format.csv { send_data(Iconv.conv('shift-jis//IGNORE', 'utf-8', cvs_string2), :filename => namefile2, :type => "text/csv",  :charset => "shift-jis") }
    end
    else
    end
 end

  def exportMenu(tantogroupcode)
    connection = Connection.new();
    header = '担当グループコード, メニューコード, メニュー名称, 親メニューコード, 表示順序, 更新担当者コード, 更新プログラム, 更新日時, 入力日時, 新規行フラグ, 行番号'    
      selectQuery = "SELECT a.担当グループコード";
      selectQuery += ", a.メニューコード"
      selectQuery += ", a.メニュー名称"
      selectQuery += ", a.親メニューコード"
      selectQuery += ", a.表示順序"
      selectQuery += ", a.更新担当者コード"
      selectQuery += ", a.更新プログラム"
      selectQuery += ", a.更新日時"
      selectQuery += ", a.入力日時"
      #selectQuery += ", 0  AS  新規行フラグ" 
      #selectQuery += ", 0    AS  行番号"   
      selectQuery += " FROM  メニューマスタ a "
      selectQuery += " WHERE a.担当グループコード  = '" + tantogroupcode + "'"
        
      menumasutaModels = Array.new;
      models1 = Hash.new;
      models1 = connection.ExecuteSelectQuery(selectQuery);  
      index = 0
      if models1.nil? then
        models1 = Hash.new;
      end
      
      models1.each do |hashValue|
        record = Menumasuta.new("");
        record.puts(hashValue);
        menumasutaModels[index] = record;
        index = index + 1;
      end
      
      if menumasutaModels.nil? then
        menumasutaModels = Array.new;
      end
      
      csv_string = header
      
        menumasutaModels.each do |model|
        line = Publicfunction.pf_nvl_string(model.担当グループコード, "")

        line += ',"' + Publicfunction.pf_nvl_string(model.メニューコード, "") + '"'
        line += ',"' + Publicfunction.pf_nvl_string(model.メニュー名称, "") + '"'
        line += ',"' + Publicfunction.pf_nvl_string(model.親メニューコード, "") + '"'        
        line += ',"' + Publicfunction.pf_nvl_number(model.表示順序, "0").to_s + '"'
        line += ',"' + Publicfunction.pf_nvl_string(model.更新担当者コード, "") + '"'
        line += ',"' + Publicfunction.pf_nvl_string(model.更新プログラム, "") + '"'
        
        if !model.更新日時.nil? then
          line += ',"' + model.更新日時.strftime("%Y/%m/%d %H:%M:%S") + '"'                   
        else
          line += ',"' + ' "'
        end
        
        if !model.入力日時.nil? then 
          line += ',"' + model.入力日時.strftime("%Y/%m/%d %H:%M:%S") + '"'       
        else
          line += ',"' + '"'
        end  
        line += ',0'
        line += ',0'             
        csv_string += "\r\n" + line; 
       end 
        return csv_string
  end 
  
  def exportGroup(tantogroupcode)
    connection = Connection.new();
    header = '担当グループコード, メニューコード, 画面プログラム, 画面名称, 権限区分, 表示順序, ボタン名称, 更新担当者コード, 更新プログラム, 更新日時, 入力日時, 新規行フラグ, 行番号'
    selectQuery = "SELECT a.担当グループコード"
    selectQuery += ", a.メニューコード"
    selectQuery += ", a.画面プログラム"
    selectQuery += ", b.画面名称"
    selectQuery += ", a.権限区分"
    selectQuery += ", a.表示順序"
    selectQuery += ", a.ボタン名称"      
    selectQuery += ", a.更新担当者コード"
    selectQuery += ", a.更新プログラム"
    selectQuery += ", a.更新日時"
    selectQuery += ", a.入力日時"
    selectQuery += " FROM  担当グループ別画面マスタ a "
    selectQuery += " ,  画面マスタ b "
    selectQuery += " WHERE a.画面プログラム = b.画面プログラム(+)" 
    selectQuery += " AND a.担当グループコード  = '" + tantogroupcode + "'"     
    selectQuery += " ORDER BY  a.メニューコード"
    
    models = Array.new;
    models1 = Hash.new;
    models1 = connection.ExecuteSelectQuery(selectQuery);      
    index = 0
    if models1.nil? then
      models1 = Hash.new;
    end
    
    models1.each do |hashValue|
       record = Tantogroupbetugamenmasuta.new("");
       record.puts(hashValue);
       models[index] = record;
       index = index + 1;
    end
    
   if models.nil? then
     models = Array.new;
   end
   csv_string = header
  
   models.each do |model|      
     line = Publicfunction.pf_nvl_string(model.担当グループコード, "") 
     
     line += ',"' + Publicfunction.pf_nvl_string(model.メニューコード, "") + '"'
     line += ',"' + Publicfunction.pf_nvl_string(model.画面プログラム, "") + '"'
     line += ',"' + Publicfunction.pf_nvl_string(model.画面名称, "") + '"'
     line += ',"' + Publicfunction.pf_nvl_string(model.権限区分, "") + '"'
     line += ',"' + Publicfunction.pf_nvl_number(model.表示順序, "0").to_s + '"'
     line += ',"' + Publicfunction.pf_nvl_string(model.ボタン名称, "") + '"'
     line += ',"' + Publicfunction.pf_nvl_string(model.更新担当者コード, "") + '"'
     line += ',"' + Publicfunction.pf_nvl_string(model.更新プログラム, "") + '"'
     
     if !model.更新日時.nil? then
       line += ',"' + model.更新日時.strftime("%Y/%m/%d %H:%M:%S") + '"'
     else
       line += ',"' + ' "'
     end
     
     if !model.入力日時.nil? then
       line += ',"' + model.入力日時.strftime("%Y/%m/%d %H:%M:%S") + '"'
     else
       line += ',"' + '"'
     end
     line +=' ,0'
     line +=' ,0'     
     csv_string += "\r\n" + line;
    end
     return csv_string
  end 
#End Add  
  def exportcsv(screen, tantogroupcode, parentmenucode)
    if parentmenucode == "00" then
      parentmenucode = " "
    end
    # 1. create connection
    connection = Connection.new();
    # begin using csv
    
    
    #Delete by bdlong 5/10/2012
    #namefile = "メニューマスタ.csv"
    # End Delete
    #ADD by bdlong 5/10/2012 
    namefile=Iconv.conv('shift-jis', 'utf-8', "メニューマスタ.csv");  
    #END Add
    if screen == "2" then
      # 担当グループ別画面マスタ
      #Delete by bdlong 5/10/2012
      #namefile = "担当グループ別画面マスタ.csv"
      # End Delete
      #ADD by bdlong 5/10/2012       
      namefile=Iconv.conv('shift-jis', 'utf-8', "担当グループ別画面マスタ.csv");  
      #End Add
      header = '担当グループコード, メニューコード, 画面プログラム, 画面名称, 権限区分, 表示順序, ボタン名称, 更新担当者コード, 更新プログラム, 更新日時, 入力日時'
      #**** get data for 担当グループ別画面マスタ
       selectQuery = "SELECT a.担当グループコード"
       selectQuery += ", a.メニューコード"
       selectQuery += ", a.画面プログラム"
       selectQuery += ", b.画面名称"
       selectQuery += ", a.権限区分"
       selectQuery += ", a.表示順序"
       selectQuery += ", a.ボタン名称"      
       selectQuery += ", a.更新担当者コード"
       selectQuery += ", a.更新プログラム"
       selectQuery += ", a.更新日時"
       selectQuery += ", a.入力日時"
       selectQuery += " FROM  担当グループ別画面マスタ a "
       selectQuery += " ,  画面マスタ b "
       selectQuery += " WHERE a.画面プログラム = b.画面プログラム(+)" 
       selectQuery += " AND a.担当グループコード  = '" + tantogroupcode + "'"
       selectQuery += " AND a.メニューコード  = '" + parentmenucode + "'"
       # select with menu is child of root.
       selectQuery += " ORDER BY  a.メニューコード"
       selectQuery += ", a.表示順序"      
       selectQuery += ", a.画面プログラム"
       
       models = Array.new;
       models1 = Hash.new;
       models1 = connection.ExecuteSelectQuery(selectQuery);      
       index = 0
       if models1.nil? then
         models1 = Hash.new;
       end
       
       models1.each do |hashValue|
          record = Tantogroupbetugamenmasuta.new("");
          record.puts(hashValue);
          models[index] = record;
          index = index + 1;
       end
       
      if models.nil? then
        models = Array.new;
      end
      csv_string = header
     
      models.each do |model|
        #Delete by nmhuyen 12/10/2012 for 010
        #line = ""        
        #line += ',"' + Publicfunction.pf_nvl_string(model.担当グループコード, "") + '"'
        #End Del
        #Add by nmhuyen 12/10/2012 for 010       
        line = Publicfunction.pf_nvl_string(model.担当グループコード, "") 
        #End Add

        
        line += ',"' + Publicfunction.pf_nvl_string(model.メニューコード, "") + '"'
        line += ',"' + Publicfunction.pf_nvl_string(model.画面プログラム, "") + '"'
        line += ',"' + Publicfunction.pf_nvl_string(model.画面名称, "") + '"'
        line += ',"' + Publicfunction.pf_nvl_string(model.権限区分, "") + '"'
        line += ',"' + Publicfunction.pf_nvl_number(model.表示順序, "0").to_s + '"'
        line += ',"' + Publicfunction.pf_nvl_string(model.ボタン名称, "") + '"'
        line += ',"' + Publicfunction.pf_nvl_string(model.更新担当者コード, "") + '"'
        line += ',"' + Publicfunction.pf_nvl_string(model.更新プログラム, "") + '"'
        if !model.更新日時.nil? then
          # Del by nmhuyen 12/10/2012 
          #line += ',"' + model.更新日時.to_formatted_s(:default) + '"'
          #End Del
          # Add by nmhuyen 12/10/2012 
          line += ',"' + model.更新日時.strftime("%Y/%m/%d %H:%M:%S") + '"'
            #End Add
        else
          line += ',"' + ' "'
        end
        
        if !model.入力日時.nil? then
          # Del by nmhuyen 12/10/2012 
          #line += ',"' + model.入力日時.to_formatted_s(:default) + '"'
          #End Del
          # Add by nmhuyen 12/10/2012 
          line += ',"' + model.入力日時.strftime("%Y/%m/%d %H:%M:%S") + '"'
           #End Add
        else
          line += ',"' + '"'
        end
        
        csv_string += "\r\n" + line;
      end
    else
      # メニューマスタ
      
      #Delete by bdlong 5/10/2012
      #namefile = "メニューマスタ.csv"
      # End Delete
      #ADD by bdlong 5/10/2012    
      namefile=Iconv.conv('shift-jis', 'utf-8', "メニューマスタ.csv");
      #End Add
      header = '担当グループコード, メニューコード, メニュー名称, 親メニューコード, 表示順序, 更新担当者コード, 更新プログラム, 更新日時, 入力日時'
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
      selectQuery += " WHERE a.担当グループコード  = '" + @tantogroupcode + "'"
      # select with menu is child of root.
      selectQuery += " AND  a.親メニューコード = '" + parentmenucode + "'"
      selectQuery += " ORDER BY  a.親メニューコード"
      selectQuery += ", a.表示順序"      
      selectQuery += ", a.メニューコード"
      menumasutaModels = Array.new;
      models1 = Hash.new;
      models1 = connection.ExecuteSelectQuery(selectQuery);  
      index = 0
      if models1.nil? then
        models1 = Hash.new;
      end
      
      models1.each do |hashValue|
        record = Menumasuta.new("");
        record.puts(hashValue);
        menumasutaModels[index] = record;
        index = index + 1;
      end
      
      if models.nil? then
        models = Array.new;
      end
      csv_string = header
       
         #Delete by nmhuyen 12/10/2012 for 010
         #models.each do |model|
         #End Del
         #Add by nmhuyen 12/10/2012 for 010
         menumasutaModels.each do |model|
         #End Add
         #Delete by nmhuyen 12/10/2012 for 010
         #line = ""        
         #line += ',"' + Publicfunction.pf_nvl_string(model.担当グループコード, "") + '"'
         #End Del
        #Add By nmhuyen 12/10/2012 for 010
        line = Publicfunction.pf_nvl_string(model.担当グループコード, "")
        #End Add
        line += ',"' + Publicfunction.pf_nvl_string(model.メニューコード, "") + '"'
        line += ',"' + Publicfunction.pf_nvl_string(model.メニュー名称, "") + '"'
        line += ',"' + Publicfunction.pf_nvl_string(model.親メニューコード, "") + '"'        
        line += ',"' + Publicfunction.pf_nvl_number(model.表示順序, "0").to_s + '"'
        line += ',"' + Publicfunction.pf_nvl_string(model.更新担当者コード, "") + '"'
        line += ',"' + Publicfunction.pf_nvl_string(model.更新プログラム, "") + '"'
        if !model.更新日時.nil? then
          # Del by nmhuyen 12/10/2012 
          #line += ',"' + model.更新日時.to_formatted_s(:default) + '"'
          #End Del
          # Add by nmhuyen 12/10/2012 
          line += ',"' + model.更新日時.strftime("%Y/%m/%d %H:%M:%S") + '"'
           #End Add          
        else
          line += ',"' + ' "'
        end
        
        if !model.入力日時.nil? then
          # Del by nmhuyen 12/10/2012 
          #line += ',"' + model.入力日時.to_formatted_s(:default) + '"'
          #End Del
          # Add by nmhuyen 12/10/2012 
          line += ',"' + model.入力日時.strftime("%Y/%m/%d %H:%M:%S") + '"'
          #End Add 
        else
          line += ',"' + '"'
        end
        
        csv_string += "\r\n" + line;
      end
    end
    
    # csv_string = lines
    # end using csv
    
    #end get list tanto group
    respond_to do |format|
      format.csv { send_data(Iconv.conv('shift-jis//IGNORE', 'utf-8', csv_string), :filename => namefile, :type => "text/csv",  :charset => "shift-jis") }
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
    #GET PARAMS
    @screen = Publicfunction.pf_nvl_string(params[:screen], "")
    if @screen == "1" then
      # メニューマスタ
      # get id from request.
      @id = Publicfunction.pf_nvl_string(params[:id], "");
      #process id (id contains 担当者コード and 画面プログラム)
      idList = Array.new
      idList = Publicfunction.pf_csv_cut(@id)
      @tantogroupcode = ""
      @menucode = ""
      if idList.size > 0 then
        @tantogroupcode = idList[0]
        logger.info "dvquan.@tantocode: " + @tantogroupcode
      end
      
      if idList.size > 1 then
          @menucode = idList[1]
          logger.info "dvquan.gamenprog: " + @menucode
      end
      
      if !@id.nil? then
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
        selectQuery += " WHERE a.担当グループコード  = '" + @tantogroupcode + "'"
        # select with menu is child of root.
        selectQuery += " AND  a.メニューコード = '" + @menucode + "'"
        records = @connection.ExecuteSelectQuery(selectQuery);
        @model = Menumasuta.new("");
        if !records.nil? && !records[0].nil?
          @model.puts(records[0]);
        end
      end 
    else
      # 担当グループ別画面マスタ
      # get id from request.
      @id = Publicfunction.pf_nvl_string(params[:id], "");
      #process id (id contains 担当者コード and 画面プログラム)
      idList = Array.new
      idList = Publicfunction.pf_csv_cut(@id)
      @tantogroupcode = ""
      @gamenprogcode = ""
      if idList.size > 0 then
        @tantogroupcode = idList[0]
        logger.info "dvquan.@tantocode: " + @tantogroupcode
      end
      
      if idList.size > 1 then
          @gamenprogcode = idList[1]
          logger.info "dvquan.gamenprog: " + @gamenprogcode
      end
      
      if !@id.nil? then
        #**** get data for 担当グループ別画面マスタ
        selectQuery = "SELECT a.担当グループコード"
        selectQuery += ", a.メニューコード"
        selectQuery += ", a.画面プログラム"
        selectQuery += ", b.画面名称"
        selectQuery += ", a.権限区分"
        selectQuery += ", a.表示順序"
        selectQuery += ", a.ボタン名称"      
        selectQuery += ", a.更新担当者コード"
        selectQuery += ", a.更新プログラム"
        selectQuery += ", a.更新日時"
        selectQuery += ", a.入力日時"
        selectQuery += ", c.メニュー名称"
        selectQuery += " FROM  担当グループ別画面マスタ a "
        selectQuery += " ,  画面マスタ b "
        selectQuery += " ,  メニューマスタ c "         
        selectQuery += " WHERE a.画面プログラム = b.画面プログラム(+)"
        selectQuery += " AND a.担当グループコード  = c.担当グループコード(+)" 
        selectQuery += " AND a.メニューコード  = c.メニューコード(+)"
        selectQuery += " AND a.担当グループコード  = '" + @tantogroupcode + "'"
        selectQuery += " AND a.画面プログラム  = '" + @gamenprogcode + "'"
         
        records = @connection.ExecuteSelectQuery(selectQuery);          
        @model = Tantogroupbetugamenmasuta.new("");
        if !records.nil? && !records[0].nil?
          @model.puts(records[0]);
        end
        #Reference table
        @gamenList = GetGamenListWithTantogroup(@tantogroupcode)
      end      
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
    #GET PARAMS
    @screen = Publicfunction.pf_nvl_string(params[:screen], "")
    if @screen == "1" then
      # 2. get id from request.
      # メニューマスタ
      # get id from request.
      @id = Publicfunction.pf_nvl_string(params[:id], "");
      #process id (id contains 担当者コード and 画面プログラム)
      idList = Array.new
      idList = Publicfunction.pf_csv_cut(@id)
      @tantogroupcode = ""
      @menucode = ""
      if idList.size > 0 then
        @tantogroupcode = idList[0]
        logger.info "dvquan.@tantocode: " + @tantogroupcode
      end
      
      if idList.size > 1 then
          @menucode = idList[1]
          logger.info "dvquan.gamenprog: " + @menucode
      end
      
      if !@id.nil? then
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
        selectQuery += " WHERE a.担当グループコード  = '" + @tantogroupcode + "'"
        # select with menu is child of root.
        selectQuery += " AND  a.メニューコード = '" + @menucode + "'"
        records = @connection.ExecuteSelectQuery(selectQuery);
        @model = Menumasuta.new("");
        if !records.nil? && !records[0].nil?
          @model.puts(records[0]);
        end
      end 
      
      #4. get form edit
      # get sytemdate
      sysdate = @connection.GetSystemDate;
      sysdateString = "TO_DATE('" + sysdate + "','YYYY/MM/DD HH24:MI:SS')";
      tantoCode = session["tantocode"];
      if tantoCode.nil?
        tantoCode = " "
      end
      # フォームのデータを取ります。params[フォーム名刺]
      param = params[:input_form]

      @model.メニュー名称 = param[:メニュー名称];
      orderstring = Publicfunction.pf_nvl_string(param[:表示順序], "1");
      Rails.logger.info "INIT: 2: tantogroupcode: "   + @model.担当グループコード + " : @parentmenucode" + @model.メニューコード
      orderNum = 1.00
      begin
        orderNum = orderstring.to_f
      rescue
        orderNum = 1.00
      end
      @model.表示順序 = orderNum;
      updateQuery = "UPDATE メニューマスタ "
      updateQuery += " SET メニュー名称 = " + ActiveRecord::Base.sanitize(@model.メニュー名称) + "";
      updateQuery += ", 表示順序 = " + ActiveRecord::Base.sanitize(@model.表示順序) + "";
      updateQuery += ", 更新担当者コード = '" + tantoCode + "'";
      updateQuery += ", 更新日時 = " + sysdateString; 
      updateQuery += " WHERE 担当グループコード = '" + @model.担当グループコード + "'";    
      updateQuery += " AND メニューコード = '" + @model.メニューコード + "'";
      
    else
      # 担当グループ別画面マスタ
      # get id from request.
      @id = Publicfunction.pf_nvl_string(params[:id], "");
      #process id (id contains 担当者コード and 画面プログラム)
      idList = Array.new
      idList = Publicfunction.pf_csv_cut(@id)
      @tantogroupcode = ""
      @gamenprogcode = ""
      if idList.size > 0 then
        @tantogroupcode = idList[0]
        logger.info "dvquan.@tantocode: " + @tantogroupcode
      end
      
      if idList.size > 1 then
         @gamenprogcode = idList[1]
         logger.info "dvquan.gamenprog: " + @gamenprogcode
      end
      
      if !@id.nil? then
        #**** get data for 担当グループ別画面マスタ
        selectQuery = "SELECT a.担当グループコード"
        selectQuery += ", a.メニューコード"
        selectQuery += ", a.画面プログラム"
        selectQuery += ", b.画面名称"
        selectQuery += ", a.権限区分"
        selectQuery += ", a.表示順序"
        selectQuery += ", a.ボタン名称"      
        selectQuery += ", a.更新担当者コード"
        selectQuery += ", a.更新プログラム"
        selectQuery += ", a.更新日時"
        selectQuery += ", a.入力日時"
        selectQuery += ", c.メニュー名称"
        selectQuery += " FROM  担当グループ別画面マスタ a "
        selectQuery += " ,  画面マスタ b "
        selectQuery += " ,  メニューマスタ c "         
        selectQuery += " WHERE a.画面プログラム = b.画面プログラム(+)"
        selectQuery += " AND a.担当グループコード  = c.担当グループコード(+)" 
        selectQuery += " AND a.メニューコード  = c.メニューコード(+)"
        selectQuery += " AND a.担当グループコード  = '" + @tantogroupcode + "'"
        selectQuery += " AND a.画面プログラム  = '" + @gamenprogcode + "'"
         
        records = @connection.ExecuteSelectQuery(selectQuery);          
        @model = Tantogroupbetugamenmasuta.new("");
        if !records.nil? && !records[0].nil?
          @model.puts(records[0]);
        end
        
        #4. get form edit
        # get sytemdate
        sysdate = @connection.GetSystemDate;
        sysdateString = "TO_DATE('" + sysdate + "','YYYY/MM/DD HH24:MI:SS')";
        tantoCode = session["tantocode"];
        if tantoCode.nil?
          tantoCode = " "
        end
        # フォームのデータを取ります。params[フォーム名刺]
        param = params[:input_form]
        
        @model.権限区分 = param[:権限区分];
        @model.ボタン名称 = param[:ボタン名称];
        orderstring = Publicfunction.pf_nvl_string(param[:表示順序], "1");        
        orderNum = 1.00
        begin
          orderNum = orderstring.to_f
        rescue
          orderNum = 1.00
        end
        @model.表示順序 = orderNum;
        updateQuery = "UPDATE 担当グループ別画面マスタ "
        updateQuery += " SET 権限区分 = " + ActiveRecord::Base.sanitize(@model.権限区分) + "";
        updateQuery += ", 表示順序 = " + ActiveRecord::Base.sanitize(@model.表示順序) + "";
        updateQuery += ", ボタン名称 = " + ActiveRecord::Base.sanitize(@model.ボタン名称) + "";
        updateQuery += ", 更新担当者コード = '" + tantoCode + "'";
        updateQuery += ", 更新日時 = " + sysdateString; 
        updateQuery += " WHERE 担当グループコード = '" + @model.担当グループコード + "'";    
        updateQuery += " AND 画面プログラム = '" + @model.画面プログラム + "'";

        #Reference table
        @gamenList = GetGamenListWithTantogroup(@model.担当グループコード)
      end
    end
    

    
    # 5. update and render action.
    respond_to do |format|
      begin
          result = @connection.ExecuteQuery(updateQuery);
          # redirect_to :controller=>'seisankankatukoujoumasuta', :action => 'show'
          if result == "0"
            @model.message ="更新に成功しまた."           
            format.html { redirect_to :controller => "menumasuta", :action => "show", :id => @id, screen: @screen, notice: '更新に成功しまた.' };
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
    @screen = 
    #GET PARAMS
    @screen = Publicfunction.pf_nvl_string(params[:screen], "")
    # 1. get id from request.
    @id = Publicfunction.pf_nvl_string(params[:id], "");
    #process id (id contains 担当者コード and 画面プログラム)
    idList = Array.new
    idList = Publicfunction.pf_csv_cut(@id)
    @tantogroupcode = ""
    @gamenprog = ""
    @menucode = ""
    if idList.size > 0 then
      @tantogroupcode = idList[0]
      logger.info "dvquan.@tantocode: " + @tantogroupcode
    end
    
    if idList.size > 1 then
        @gamenprog = idList[1]
        @menucode = idList[1]
        logger.info "dvquan.gamenprog: " + @gamenprog
    end
    
    #2. create sql 
    if @screen == "1" then
      # メニューマスタ
      deleteQuery = "DELETE FROM メニューマスタ "
      deleteQuery += " WHERE 担当グループコード = '" + @tantogroupcode + "'";    
      deleteQuery += " AND メニューコード = '" + @menucode + "'";
    else
      # メニューマスタ
      deleteQuery = "DELETE FROM 担当グループ別画面マスタ "
      deleteQuery += " WHERE 担当グループコード = '" + @tantogroupcode + "'";    
      deleteQuery += " AND 画面プログラム = '" + @gamenprog + "'";    
    end
    
    #3. exec sql and return
    respond_to do |format|    
      begin
        result = @connection.ExecuteQuery(deleteQuery);
        # redirect_to :controller=>'seisankankatukoujoumasuta', :action => 'index'
        if result == "0"
          format.html { redirect_to :controller => "menumasuta", :action => "index", notice: '削除に成功しました。', screen: @screen, tantogroupcode: @tantogroupcode}
          format.json { head :no_content }
        else
          format.html { redirect_to :controller => "menumasuta", :action => "index", notice: '削除に失敗しました。', screen: @screen, tantogroupcode: @tantogroupcode}
          format.json { head :no_content }
        end
      rescue
        format.html { redirect_to :controller => "menumasuta", :action => "index", notice: '削除に失敗しました。'}
        format.json { head :no_content }
      ensure 
      end
    end
  end
#-------------------------------- Function for pages. --------------------------------------------
  def wf_CreateTree(models, tantomenufocus, tantogroupcode)
    htmlString = " "
    #Delete by nmhuyen 9/10/2012
    #focucode = "00"
    #End Del
    #Add By nmhuyen 9/10/2012
    focucode = ""
    #End Add
    if !tantomenufocus.nil? && tantomenufocus != "" then
      focucode = tantomenufocus
    end
    
    Rails.logger.info 'dvquan.wf_CreateTree: focucode= ' + focucode.to_s
    closeTagList = Array.new
    countTag = 0
    oldlevel = 0
    index = 0
    recordCount = 0
    if !models.nil? then
      recordCount = models.size
    end
    #Delete by nmhuyen 9/10/2012
    #oldId = "00"
    #End Del
    #Add By nmhuyen 9/10/2012
    oldId = ""
    #End Add
    
    firstItem = "1"
    nextId = ""
    nextlevel = 0
    models.each do |model|
      curlevel = model.レベル
      id = model.メニューコード
      nameshow =  model.メニュー名称
      #Delete by nmhuyen 9/10/2012
      #if id.strip == "" then
      #  id = "00" #root
      #end
      #End Delete
      #Add By nmhuyen 9/10/2012
      if id.strip == "" then
        id = "" #root
      end
      #End Add
      if index < recordCount - 1 then
        nextId = models[index + 1].メニューコード
        nextlevel = models[index + 1].レベル
      else
        nextId = ""
        nextlevel = 0
      end
      #Delete by nmhuyen 9/10/2012
      #if id == "00" then
      #End Del
      #Add By nmhuyen 9/10/2012
      if id == "" then
      #End Add
        iconTag = wf_CreateImageNodeButton(id, 3)
      else
        if id == focucode then
          iconTag = wf_CreateImageNodeButton(id, 1)
        else
          iconTag = wf_CreateImageNodeButton(id, 0)
        end
      end
      
      if curlevel > oldlevel then
        # go down level
        
        if firstItem == "1" then
          htmlString += "<ul id='ul_root'>"
          firstItem = "0"
        else
          #Delete by nmhuyen 9/10/2012
          #if oldId == "00" then
          #End Del
          #Add By nmhuyen 9/10/2012          
          if oldId == "" then
          #End Add
            htmlString += "<ul id='ul_" + oldId.to_s + "'>"
          else
            htmlString += "<ul id='ul_" + oldId.to_s + "' style='display:none;' class='listmenuleft'>"
          end
        end
        htmlString += "<li>"
        
        # atag = "<a id='" + id + "' href='javascript:void;' onclick='menuchange(this)'>"
        atag = "<a id='" + id + "' href='javascript:void(0);' onclick='menumasutachange(this,\"" + tantogroupcode + "\")'>"
        atag += iconTag
        # Add by HuyenNM 3/10/2012 fix code menu 
        atag += id + "  "
        # End Add
        atag += nameshow
        atag += "</a>"
        # check child link
        if nextlevel != 0 then
          if curlevel < nextlevel then
            # child include
            showTag = wf_CreateChildShowButton(id, 0)
            if !showTag.nil? then
              atag = showTag + atag
            end
          end
        end
        
        htmlString += atag
        countTag = countTag + 1
        closeTagList[countTag] = "</ul>"
        countTag = countTag + 1
        closeTagList[countTag] = "</li>"
      end
      
      if curlevel == oldlevel then
        htmlString += closeTagList[countTag]
        countTag = countTag - 1
        # atag = "<a id='" + id + "' href='javascript:void;' onclick='menuchange(this)'>"
        atag = "<a id='" + id + "' href='javascript:void(0);' onclick='menumasutachange(this,\"" + tantogroupcode + "\")'>"
        atag += iconTag
        # Add by HuyenNM 3/10/2012 fix code menu 
        atag += id + "  "
        # End Add
        atag += nameshow
        atag += "</a>"
        # check child link
        if nextlevel != 0 then
          if curlevel < nextlevel then
            # child include
            showTag = wf_CreateChildShowButton(id, 0)
            if !showTag.nil? then
              atag = showTag + atag
            end
          end
        end
        
        htmlString += "<li>"
        htmlString += atag
        countTag = countTag + 1
        closeTagList[countTag] = "</li>"       
      end
      
      if curlevel < oldlevel then
        # go up level
        countUp = (oldlevel - curlevel)*2
        # close some tag
        while countUp > 0 && countTag > 0 do
          htmlString += closeTagList[countTag]
          countTag = countTag - 1          
          countUp = countUp - 1
        end
        
        # atag = "<a id='" + id + "' href='javascript:void;' onclick='menuchange(this," + tantogroupcode + ")'>"
        atag = "<a id='" + id + "' href='javascript:void(0);' onclick='menumasutachange(this,\"" + tantogroupcode + "\")'>"
        atag += iconTag
        # Add by HuyenNM 3/10/2012 fix code menu 
        atag += id + "  "
        # End Add        
        atag += nameshow
        atag += "</a>" 
        # check child link
        if nextlevel != 0 then
          if curlevel < nextlevel then
            # child include
            showTag = wf_CreateChildShowButton(id, 0)
            if !showTag.nil? then
              atag = showTag + atag
            end
          end
        end
        
        htmlString += "<li>"
        htmlString += atag      
        countTag = countTag + 1
        closeTagList[countTag] = "</li>"       
      end
            
      oldlevel = curlevel
      oldId = id
      index = index + 1
    end
    
    return htmlString;
  end
  
  def wf_CreateChildShowButton(id, mode)
    # id = id of ul(child)
    htmlString = ""
    if id == "00" then
      # root expand
      htmlString = "<a href='javascript:void(0);' class='showhidebutton' id='show_" + id + "' onclick='showhidenode(this)'> -- </a>"
      return htmlString
    end
    if mode == 0 then
      # child not show
      htmlString = "<a href='javascript:void(0);' class='showhidebutton' id='show_" + id + "' onclick='showhidenode(this)'> + </a>"
    else
      htmlString = "<a href='javascript:void(0);' class='showhidebutton' id='show_" + id + "' onclick='showhidenode(this)'> -- </a>"
    end
    
    Rails.logger.info 'dvquan.wf_CreateChildShowButton.showButton: ' + htmlString
    return htmlString
  end
  
  def wf_CreateImageNodeButton(id, mode)
    # id current node
    htmlString = ""
    if mode == 3 then
      # root folder
      htmlString = "<span class='root' id='root_" + id + "' ></span>"
      return  htmlString
    end
    
    if mode == 1 then
      htmlString = "<span class='selected' id='select_" + id + "' ></span>"
    else
      # not selected
      htmlString = "<span class='notselected' id='select_" + id + "' ></span>"
    end
    
    Rails.logger.info 'dvquan.wf_CreateImageNodeButton.showButton: ' + htmlString
    return htmlString
  end
  
  def wf_GetParentMenuInfor(connection, termId, menucode)
    #メニューリストを取得する。
    selectQuery = "SELECT a.端末番号"
    selectQuery += ", a.表示ラベル"
    selectQuery += ", a.レベル"
    selectQuery += ", a.ツリー順序"
    selectQuery += ", a.メニューコード"
    selectQuery += ", a.フォーカスフラグ"
    selectQuery += ", a.メニュー名称"
    selectQuery += ", 0 AS  ハンドル"

    selectQuery += " FROM  MAIN001_テンプ a "
    selectQuery += " WHERE a.端末番号  = " + (Integer(termId)).to_s()
    selectQuery += " AND  メニューコード = '" + menucode + "'"
    
    record = Menu001_temp.new(1); 
    @models1 = Hash.new;
    @models1 = connection.ExecuteSelectQuery(selectQuery);
    index = 0
    @models1.each do |hashValue|
      record = Menu001_temp.new(1);
      record.puts(hashValue);
    end
    
    return record
  end
  
  def GetGamenListWithTantogroup(tantogroupcode)
    # 1. create connection
    connection = Connection.new();
    # get tantogroup from tantoCode
    
    # 2. query
    where = " where  exists  ( select  1 "
    where += " from    担当グループ別画面マスタ  b"
    where += " where   b.画面プログラム   = a.画面プログラム "
    # where += " and   b.担当グループコード = '"  + tantogroupcode + "'  "
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