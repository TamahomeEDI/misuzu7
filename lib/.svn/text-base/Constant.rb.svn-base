#!/bin/env ruby
# encoding: utf-8
require 'logger.rb'
class Constant
  #================================================================
  #   名　称    Constant
  #   説　明    oracleに連結を作る。
  #   補　足
  #   引　数 なし
  #   戻　値
  # (history)
  #   date         ver        name          comments
  #  -------     -----      ----------  -----------------
  #  2012.10.11  1.00.00     dinhlong.org@gmail.com       新規作成
  #=================================================================
  @config   = Rails.configuration.database_configuration
  def self.userName
    return @config[Rails.env]["username"];
  end
    
  def self.serverName
    return @config[Rails.env]["database"];
  end
    
end