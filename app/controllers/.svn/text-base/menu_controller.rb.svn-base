#!/bin/env ruby
# encoding: utf-8
class MenuController < BaseController
  layout :resolve_layout
  def self.GetVersion
      return "ver.1.00.00";
  end
    
  def resolve_layout
    #using for future
    case action_name
    when "list"
      "partial"
    else
      "application"
    end
  end

  def index
    # Action Index
    tantoname = session["tantoname"]
    if tantoname.nil?
      tantoname = "";
    end
    @connection = Connection.new();
    @pageTitle = "main001 メインメニュー(" + MenuController.GetVersion + ")-[" + tantoname + "]" + "- [" + @connection.DatabaseUserName + "@" + @connection.DatabaseServer + "]";
    termId = session["termid"]
    tantogroupcode = session["tantogroupcode"]
    tantomenufocus = session["tantomenufocus"]
    if tantogroupcode.nil? then
      tantogroupcode = ""
    end
    
    if tantomenufocus.nil? then
      tantomenufocus = ""
    end
    
    @tantocode = session["tantocode"];
    #メニューリストを作成する。
    query = "CALL P_MAIN001(" + termId.to_s + ", '" + tantogroupcode + "','' )";
    result = @connection.ExecuteQuery(query);
    #画面のデータを作成する。
    query = "CALL P_MAIN001_3(" + termId.to_s + ",'" + @tantocode + "')"
    result2 = @connection.ExecuteQuery(query);
    if(result == "0" && result2 == "0") then
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

      @htmlString = wf_CreateTree(@models, tantomenufocus)
      
      Rails.logger.info 'dvquan.IndexAction.HTML menu index: ' + @htmlString
      #画面のデータを取得する。
      selectQuery = "SELECT  a.メニューコード"
      selectQuery += ",     a.画面プログラム"  
      selectQuery += ",      a.権限区分"     
      selectQuery += ",      a.表示順序" 
      selectQuery += ",      a.ボタン名称"
      selectQuery += ",     a.ウィンドウ名称"   
      selectQuery += " FROM    MAIN001_テンプ_2 a"
      selectQuery += " WHERE   a.端末番号  = " + (Integer(termId)).to_s()
      selectQuery += " AND   a.権限区分  <>  '0'"
      selectQuery += " ORDER BY a.メニューコード"
      selectQuery += " , a.表示順序"
      selectQuery += " , a.画面プログラム"      
      @models = Array.new;    
      @models1 = Hash.new;
      @models1 = @connection.ExecuteSelectQuery(selectQuery);
      index = 0
      @models1.each do |hashValue|
        record = Menu002_temp.new(1);
        record.puts(hashValue);
        @models[index] = record;
        index = index + 1;
      end

      @htmlStringRight = wf_CreateGamenList(@models, tantomenufocus)
      Rails.logger.info 'dvquan.IndexAction.HTML_RIGHT: ' + @htmlStringRight
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @models }
      end
    end
  end
  
# Function for pages.
  def wf_CreateTree(models, tantomenufocus)
    htmlString = " "
    focucode = "00"
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
    
    oldId = "00"
    firstItem = "1"
    nextId = ""
    nextlevel = 0
    models.each do |model|
      curlevel = model.レベル
      id = model.メニューコード
      nameshow =  model.メニュー名称
      if id.strip == "" then
        id = "00" #root
      end
      
      if index < recordCount - 1 then
        nextId = models[index + 1].メニューコード
        nextlevel = models[index + 1].レベル
      else
        nextId = ""
        nextlevel = 0
      end
      
      if id == "00" then
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
          if oldId == "00" then
            htmlString += "<ul id='ul_" + oldId.to_s + "'>"
          else
            htmlString += "<ul id='ul_" + oldId.to_s + "' style='display:none;' class='listmenuleft'>"
          end
        end
        htmlString += "<li>"
        
        atag = "<a id='" + id + "' href='javascript:void(0);' onclick='menuchange(this)'>"
        atag += iconTag
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
        atag = "<a id='" + id + "' href='javascript:void(0);' onclick='menuchange(this)'>"
        atag += iconTag
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
        
        atag = "<a id='" + id + "' href='javascript:void(0);' onclick='menuchange(this)'>"
        atag += iconTag
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
  
  def wf_CreateGamenList(models, tantomenufocus)
    oldCode = "00"
    focuscode = "00"
    if !tantomenufocus.nil? && tantomenufocus != "" then
      focuscode = tantomenufocus
    end
    
    Rails.logger.info 'dvquan.wf_CreateGamenList: focuscode= ' + focuscode.to_s
    htmlString = " "
    htmlTableHeader = "<table>"
    # DELETE by HuyenNM 21-09-2012
    #htmlTableHeader += "<tr>"
    #htmlTableHeader += "<th rowspan='2'>画面名称</th><th>画面プログラム</th>"
    #htmlTableHeader += "</tr>" 
    # += "<tr>"
    #htmlTableHeader += "<th>権限</th>"
    #htmlTableHeader += "</tr>"
    # END DELETE
    #" <div id='00' style="display: none"> " +
    if focuscode == "00" then
      htmlString = "<div class='divgamen' id='gamen_00'> " + htmlTableHeader
    else
      htmlString = "<div class='divgamen' id='gamen_00' style='display: none'> " + htmlTableHeader
    end
    
    models.each do |model|
      curCode = model.メニューコード
      href = model.ウィンドウ名称
      buttonName = model.ボタン名称
      screenName = model.画面プログラム
      # 0:使用不可 1:フル権限 2:参照のみ
      kengen = ""
      case model.権限区分
        when "0"
          kengen = "0:使用不可"
        when "1"
          kengen = "1:フル権限 "
        when "2"
          kengen = "2:参照のみ"
      end
      
      if curCode.strip == "" then
        curCode = "00" #root
      end
      
      # Rails.logger.info 'dvquan.RIGHT: curCode= ' + curCode + ' oldCode' + oldCode + ' screenName= ' + screenName
      # header
      if curCode != oldCode then
        #close old table
        htmlString += "</table></div>"
        if curCode == focuscode then
          htmlString += "<div class='divgamen' id='gamen_" + curCode + "'>"
        else
          htmlString += "<div class='divgamen' id='gamen_" + curCode + "' style='display:none;'>"
        end
        htmlString += htmlTableHeader
      end
      
      #body ボタン名称
      htmlString += "<tr>"
      htmlString += "<td rowspan='2'>"
      #htmlString += "<a class='gamenbutton' href='" + href + "'  target='_blank'>"
      htmlString += "<a class=\"#{"gamenbutton"}\" href='javascript:void(0)' onclick=\"#{"popupForm('"+ href +"')"}\" >"
      htmlString += buttonName
      htmlString += "</a>"
      htmlString += "</td>"
      # 画面プログラム
      htmlString += "<td>"
      htmlString += "<label class='gamenprograme'>"
      htmlString += screenName
      htmlString += "</label>"
      htmlString += "</td>"
      htmlString += "</tr>"
      
      #kengen
      htmlString += "<tr>"
      htmlString += "<td>"
      htmlString += "<label class='gamenprograme'>"
      htmlString += kengen
      htmlString += "</label>"
      htmlString += "</td>"
      htmlString += "</tr>"
      
      oldCode = curCode
    end
    
    # close last table
    htmlString += "</table></div>"
    return htmlString
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
end