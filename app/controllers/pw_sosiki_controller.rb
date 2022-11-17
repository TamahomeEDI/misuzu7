#!/bin/env ruby
# encoding: utf-8
require 'pw_sosiki_model.rb'
require 'controllerModel/pw_sosikicontrollerModel.rb'
class PwSosikiController < BaseController
    #================================================================
    #   名　称    PwSosikiController
    #   説　明    アクションを抑制しまた。
    #   補　足
    #   引　数 なし
    #   戻　値
    # (history)
    #   date         ver        name                      comments
    #  -------     -----      ----------------          -----------------
    #  2012.10.25  1.00.00     dinhlong.org@gmail.com       新規作成
    #=================================================================
  def index
    
    # 1. init
    # get title
    tantoname = session["tantoname"]
    if tantoname.nil?
      tantoname = "***"
    end
    Mb001Controller.getTantosya=tantoname;
    @pageTitle = Mb001Controller.getPageTitle(MB001Model.getProgId,MB001Model.getGamenName) + " <　参照モード　>"
    
    #3. Get table references
    @sosikisyubetuList = Pw_SosikicontrollerModel.getSosikiSyubetuList()
        
    #referent gamen
    @SOSEKICODE_CONTROLID=Publicfunction.pf_nvl_string(params["SOSEKICODE_CONTROLID"], "")
    @SOSEKINAME_CONTROLID=Publicfunction.pf_nvl_string(params["SOSEKINAME_CONTROLID"], "")
    @JIGYOUKI_VALUE=Publicfunction.pf_nvl_string(params["JIGYOUKI_VALUE"], "")
    @jigyokiname = Pw_SosikicontrollerModel.pf_ddw_jigyo_nengetu(@JIGYOUKI_VALUE)
    
    #2. get params
     @sosikimeisyo = Publicfunction.pf_nvl_string(params["sosikimeisyo"], "")
     @searchoption = Publicfunction.pf_nvl_string(params["searchoption"], "")
     @kobasosiki = Publicfunction.pf_nvl_string(params["kobasosiki"], "")
     @sosikisyubetu = Publicfunction.pf_nvl_string(params["sosikisyubetu"], "")
          
    @Flag = Publicfunction.pf_nvl_string(params["Flag"], "")
    
    if(@Flag=="1")
      @models=Pw_SosikicontrollerModel.selectForm(@sosikimeisyo,@searchoption,@kobasosiki,@sosikisyubetu,@JIGYOUKI_VALUE)
      render :partial => "gridForm", :object => @models
    end
    
  end
   
end