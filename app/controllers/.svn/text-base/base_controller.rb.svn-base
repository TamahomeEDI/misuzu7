#!/bin/env ruby
# encoding: utf-8
class BaseController < ApplicationController
  protect_from_forgery
  before_filter :login_required
  def login_required
    tantocode = session["tantocode"]
      if tantocode.nil? then
        redirect_to :controller=>'login', :action => 'index'
      end
  end
  
  def self.getVersion
     return "ver.1.00.00";
  end
  
  def self.getTantosya
       return session["tantoname"];
  end
  
  def self.getTantosya
      @getTantosya
  end
    
  def self.getTantosya= (value)
    @getTantosya = value
  end
  
 def self.getPageTitle(getProgId, getGamenName)
   return getProgId + " " + getGamenName + "  (" + getVersion + ")-[" + getTantosya + "]" + "- [" + Constant.userName + "@" + Constant.serverName + "]";
 end
end