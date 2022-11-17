#!/bin/env ruby
# encoding: utf-8
require 'csv' # csvファイルを出力。
require 'iconv'
require 'mb001_model.rb'
require 'controllerModel/mb_001controllerModel.rb'
require 'controllerModel/Pw_SosikicontrollerModel.rb'
require 'controllerModel/mb_001headItem.rb'
class Mb001Controller < BaseController
    #================================================================
    #   名　称    Mb001Controller
    #   説　明    アクションを抑制しまた。
    #   補　足
    #   引　数 なし
    #   戻　値
    # (history)
    #   date         ver        name                      comments
    #  -------     -----      ----------------          -----------------
    #  2012.10.11  1.00.00     dinhlong.org@gmail.com       新規作成
    #=================================================================
  def index
     # 1. init
     # get title
     tantoname = session["tantoname"]
     if tantoname.nil?
       tantoname = "***"
     end
     Mb001Controller.getTantosya=tantoname;
     @pageTitle = Mb001Controller.getPageTitle(MB001Model.getProgId,MB001Model.getGamenName)
     
    #2. get params
    @tantogroupcode = Publicfunction.pf_nvl_string(params["tantogroupcode"], "")
    @sosikicode = Publicfunction.pf_nvl_string(params["SOSIKICODE"], "")
    @sosikiname = ""
    if(!@sosikicode.blank?)
      @sosikiname = Pw_SosikicontrollerModel.getSosikiName(@sosikicode)
    end
    
    @tantocode = Publicfunction.pf_nvl_string(params["tantocode"], "")
    @searchtext = Publicfunction.pf_nvl_string(params["tantoname"], "")
    @seachoption = Publicfunction.pf_nvl_string(params["searchoption"], "1")
    @kijundate = Publicfunction.pf_nvl_string(params["kijundate"], "")
    @jigyodate = Publicfunction.pf_nvl_string(params["jigyodate"], "")
    @honjitudate = Publicfunction.pf_GetHonjitu()
    #基準日
    if(@kijundate.blank?)
      @kijundate=@honjitudate.strftime("%Y/%m/%d")
    else
      begin
       @kijundate = Date.parse(@kijundate)
      rescue
        #do something if invalid
       @kijundate = @honjitudate
      end
    end
    
    #事業日
    @jigyodate=Publicfunction.pf_GetJigyoDate(@kijundate)
    if(@jigyodate!=nil) 
      @jigyodate=@jigyodate.strftime("%Y/%m/%d")
    else
      @jigyodate=Publicfunction.pf_GetJigyoDate("").strftime("%Y/%m/%d")
    end
    
    
    #3. Get table references
    @tantoGroupList = MB_001controllerModel.getTantoGroupList()
    @initialpass=Publicfunction.pf_get_initial_str(MB001Model.getProgId,"d_mb_001_main","パスワード")
    @tantoGroupList = MB_001controllerModel.getTantoGroupList()
    @tantoList = MB_001controllerModel.getTantoList()
    
    @Flag = Publicfunction.pf_nvl_string(params["Flag"], "")
    @arrKENSAKUJYOUKEN = Array.new
    @arrKENSAKUJYOUKEN=session["arrKENSAKUJYOUKEN"];
    if(!@arrKENSAKUJYOUKEN.nil?)
       @length=@arrKENSAKUJYOUKEN[0].size
       @tantogroupcode=@arrKENSAKUJYOUKEN[0][@length-1]
       @sosikicode=@arrKENSAKUJYOUKEN[1][@length-1]
       @sosikiname=@arrKENSAKUJYOUKEN[2][@length-1]
       @jigyodate=@arrKENSAKUJYOUKEN[3][@length-1]
       @tantocode=@arrKENSAKUJYOUKEN[4][@length-1]
       @searchtext=@arrKENSAKUJYOUKEN[5][@length-1]
       @seachoption=@arrKENSAKUJYOUKEN[6][@length-1]
       @kijundate=@arrKENSAKUJYOUKEN[7][@length-1]
       @Flag=@FlagForm=@arrKENSAKUJYOUKEN[8]
       #set initial value
       @initial_jigyodate=@arrKENSAKUJYOUKEN[3][0]
       @initial_kijundate=@arrKENSAKUJYOUKEN[7][0]
       @arrKENSAKUJYOUKEN=session["arrKENSAKUJYOUKEN"]=nil
      
    end
    
    #検索条件
    @mb001heaitem=MB_001headItem.new(@tantogroupcode,@sosikicode,@sosikiname,@tantocode,@searchtext,@seachoption,@kijundate,@jigyodate)
        
    if(!@Flag.blank?)
      @models=MB_001controllerModel.selectForm(@mb001heaitem.担当グループコード,@mb001heaitem.担当者コード,@mb001heaitem.組織コード,@mb001heaitem.担当者名称曖昧,@mb001heaitem.担当者名称曖昧区分,@mb001heaitem.基準日)
      if(@Flag=="1") 
        render :partial => "gridForm", :object => @models
      else
        #4. Create csv
        # begin using csv
        @csv_string=getFormatCSV(@models,@mb001heaitem.事業年月)
        respond_to do |format|
           format.html # index.html.erb
           format.json { render json: @models }
           @fileName=Iconv.conv('shift-jis', 'utf-8', "担当者マスタ.csv");
           format.csv { send_data(Iconv.conv('shift-jis//IGNORE', 'utf-8', @csv_string), :filename => @fileName, :type => "text/csv",  :charset => "utf-8") }
        end
      end 
    end
  end
  
  def getFormatCSV(models,jigyoDate)
     header = '担当者コード, 担当者名称, 開始日, 終了日, パスワード, パスワード更新日, 組織コード, 組織名称, 担当グループコード, 担当グループ名称, ログインユーザー, フォーカス＿メニューコード, メニュー名称, 社員区分, 更新担当者コード, 更新プログラム, 更新日時, 入力日時, 新規行フラグ, 事業年月'
     csv_string = header    
     models.each do |model|
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
       line += ',"' + model.開始日.strftime("%Y/%m/%d %H:%M") + '"'
       line += ',"' + model.終了日.strftime("%Y/%m/%d %H:%M") + '"'
       line += ',"' + model.パスワード + '"'
       line += ',"' + model.パスワード更新日.strftime("%Y/%m/%d %H:%M") + '"'
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
         line += ',"' + model.更新日時.strftime("%Y/%m/%d %H:%M") + '"'
       else
         line += ',"' + ' "'
       end
       
       if !model.入力日時.nil? then
         line += ',"' + model.入力日時.strftime("%Y/%m/%d %H:%M") + '"'
       else
         line += ',"' + '"'
       end
       #新規行フラグ
       addFlag="0"
       line += ',"' + addFlag + '"'
       #事業年月
       line += ',"' + Date.parse(jigyoDate).strftime("%Y/%m/%d %H:%M") + '"'
   
         csv_string += "\r\n" + line;
     end
     # csv_string = lines
     # end using csv
           
   return   csv_string
  end
  
  def show
       id = Publicfunction.pf_nvl_string(params[:id], "")
       if id == "update_menulist" then
           # ajax function
           tantogroupcode = Publicfunction.pf_nvl_string(params[:ajax_tantogroup_code], "")
           logger.info 'update_focus_menu=>tantogroupcode:' + tantogroupcode
           @focusmenuList = MB_001controllerModel.getFocusMenuListWithTantoGroup(tantogroupcode)
           render :partial => "focusmenulist", :object => @focusmenuList
       end
       
       if id == "update_sosiki" then
         # ajax function
         kijun_date_string = Publicfunction.pf_nvl_string(params[:kijun_date], "")
         @JigyoDate=Publicfunction.pf_GetJigyoDate(kijun_date_string)
         if(@JigyoDate!=nil) 
           @JigyoDate=@JigyoDate.strftime("%Y/%m/%d")
         else
           @JigyoDate=@JigyoDate=Publicfunction.pf_GetJigyoDate("").strftime("%Y/%m/%d")
         end
         render :text => @JigyoDate
       end
       
       if id == "update_sosikiname" then
         # ajax function
          sosikicode = Publicfunction.pf_nvl_string(params[:ajax_sosiki_code], "")
          @SosikiName = Pw_SosikicontrollerModel.getSosikiName(sosikicode)
          render :xml => @SosikiName
       end
       
       if id == "checktantocode" then
          # ajax function
          tantocode = Publicfunction.pf_nvl_string(params[:tantocode], "")
          kaisijitu = Publicfunction.pf_nvl_string(params[:kaisijitu], "")
          @jyufuku = MB_001controllerModel.getTantoName(tantocode,kaisijitu)
          if(@jyufuku==0) then 
            render :xml => "0"
          else
            render :xml => "1"
          end
       end
            
     end
     
     def create
       
       @DELETECODES=params["deleteCode"]
       @FLAGS=params["flag"]
       @TANTOUSYACODES=params["TANTOUSYACODE"]#担当者コード
       @TANTOUMEISYOUS=params["TANTOUMEISYOU"]#担当者名称
       @KAISIDATES=params["KAISIDATE"]#開始日
       @SYURYOUDATES=params["SYURYOUDATE"]#終了日
       @PASSS=params["PASS"]#パスワード     
       @PASWORDUPDATEDATES=params["PASWORDUPDATEDATE"]#パスワード更新
       @SOSEKICODES=params["SOSEKICODE"]#組織コード 
       @TANTOUGROUPCODES=params["TANTOUGROUPCODE"]#担当グループコード
       @LOGINUSES=params["LOGINUSE"]#ログインユーザー
       @FOCUSMENUS=params["FOCUSMENU"]#フォーカス＿メニューコー
       @SYAINKUBUNS=params["SYAINKUBUN"]#社員区
       tantoCode = session["tantocode"];
       if tantoCode.nil?
         tantoCode = " "
       end
       @KOUSINTANTOUSYACODE=tantoCode#更新担当者コード  
       @GETPROGID=TantosyabetugamenmasutaController.GetProgId#更新プログラム 
       #更新日時, 入力日時 sysdateString = "TO_DATE('" + sysdate + "','YYYY/MM/DD HH24:MI:SS')";
       
       @arrRecord_ADDNEW=Array.new
       @arrRecord_UPDATE=Array.new
       indexAdd=0
       indexUpdate=0
       @countArray=@FLAGS.size
       for i in 1..@countArray-1
         @arrColums=Array.new
         @arrColums[0]=@TANTOUSYACODES[i]
         @arrColums[1]=@TANTOUMEISYOUS[i]
         @arrColums[2]=Publicfunction.pf_nvl_string(@KAISIDATES[i], "1900/01/01")#開始日
         @arrColums[3]=Publicfunction.pf_nvl_string(@SYURYOUDATES[i], "1900/01/01")#終了日
         @arrColums[4]=@PASSS[i]
         @arrColums[5]=Publicfunction.pf_nvl_string(@PASWORDUPDATEDATES[i], "1900/01/01")#パスワード更新
         @arrColums[6]=@SOSEKICODES[i]
         @arrColums[7]=@TANTOUGROUPCODES[i]
         @arrColums[8]=@LOGINUSES[i]
         @arrColums[9]=@FOCUSMENUS[i]
         @arrColums[10]=@SYAINKUBUNS[i]
         @arrColums[11]=@KOUSINTANTOUSYACODE
         @arrColums[12]=@GETPROGID
         
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
       
       @results=MB_001controllerModel.updateForm(@arrRecord_DELETE,@arrRecord_UPDATE,@arrRecord_ADDNEW)
       if(@results=="0") then
         #2. get params
         @arrKENSAKUJYOUKEN=Array.new
         @arrKENSAKUJYOUKEN[0]=Publicfunction.pf_format_cut(params["arrTantogroupcode"],",")
         @arrKENSAKUJYOUKEN[1]=Publicfunction.pf_format_cut(params["arrSosikicode"],",")
         @arrKENSAKUJYOUKEN[2]=Publicfunction.pf_format_cut(params["arrSosikiname"],",")
         @arrKENSAKUJYOUKEN[3]=Publicfunction.pf_format_cut(params["arrJigyodate"],",")
         @arrKENSAKUJYOUKEN[4]=Publicfunction.pf_format_cut(params["arrTantocode"],",")
         @arrKENSAKUJYOUKEN[5]=Publicfunction.pf_format_cut(params["arrTantoname"],",")
         @arrKENSAKUJYOUKEN[6]=Publicfunction.pf_format_cut(params["arrSearchoption"],",")
         @arrKENSAKUJYOUKEN[7]=Publicfunction.pf_format_cut(params["arrKijundate"],",")
         @arrKENSAKUJYOUKEN[8]=params["FlagForm"]
         session["arrKENSAKUJYOUKEN"]= @arrKENSAKUJYOUKEN
         
         #query="tantogroupcode=#{@tantogroupcode}&tantocode=#{@tantocode}&sosikicode=#{@sosikicode}&searchtext=#{@searchtext}&seachoption=#{@seachoption}&kinjundatestring=#{@kinjundatestring}&kijundatedefault=#{@kijundatedefault}"
         #render :text => "<script>alert('更新処理が完了しました。');window.location.href='/mb001?Flag=0&#{query}';</script>"
         render :text => "<script>alert('更新処理が完了しました。');window.location.href='/mb001';</script>"
         #render :text => "<script>alert('#{@arrKENSAKUJYOUKEN[0]}');</script>"
       else 
         render :text => "<script>alert('更新に失敗しましたので、確認おねがいします');window.history.go(-1);</script>"
       end
       
     end
   
end