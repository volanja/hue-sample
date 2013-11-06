# encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'net/http'
require 'json'
require 'uri'
require 'pp'
require 'date'
require "sass"
require "haml"
require "coffee-script"

set :environment, :production
set :public_folder, File.dirname(__FILE__) + '/public'
set :haml, :format => :html5
configure do
  enable :sessions
end

module Light
  class App < Sinatra::Base

    def transmit (url,method = "get", data = nil)
      uri = URI.parse(url)
      if method == "get"
        req = Net::HTTP::Get.new(uri.path)
      elsif method == "post"
        req = Net::HTTP::Post.new(uri.path)
        req.body = data
      elsif method == "put"
        req = Net::HTTP::Put.new(uri.path)
        req.body = data
      end
      pp req
      response = Net::HTTP.start(uri.host,uri.port){|http|
        http.request(req)
      }
      pp response
      return JSON.parse(response.body, {:symbolize_names => true})
    end
    get '/stylesheets/base.css' do
      scss :base
    end
    get '/' do
      url = "http://www.meethue.com/api/nupnp"
      portal = transmit(url,"get")
      if portal.empty? then @message = 'sory can not found hue' ; return end
      session[:ip] = portal[0][:internalipaddress]
      if session.has_key?(:ip) then
        @message = 'set ip!'
      else
        @message = 'sorry ip not found'
      end
      @site_name = 'hue-sample'
      @nav = ['action']
      haml:index
    end

    get '/light/:number' do
      if session.has_key?(:ip) then
        url = "http://#{session[:ip]}/api/newdeveloper/lights/#{params[:number]}"
        light = transmit(url,"get")
        pp light
        "aa"
      else
        "not ip "
      end
    end

    get '/change/:number' do
      if session.has_key?(:ip) then
        url = "http://#{session[:ip]}/api/newdeveloper/lights/#{params[:number]}/state"
        #data = '{"on":true, "sat":255, "bri":255,"hue":10000, "effect":"colorloop"}'
        if session[:on] == true
          data = '{"on":false}'
          session[:on] = false
        else
          data = '{"on":true}'
          session[:on] = true
        end
        light = transmit(url,"put",data)
        pp light
        "aa"
      else
        "not ip "
        redirect "/portal"
      end
    end

    get '/sched/:number' do
      if session.has_key?(:ip) then
        after5 = Time.now + 5
        pp after5.iso8601
        url = "http://#{session[:ip]}/api/newdeveloper/lights/#{params[:number]}/state"
        if session[:on] == true
          data = '{"command":{"address":"/api/newdeveloper/lights/3/state","method":"PUT","body":{"on":false}}, "time":#{}}' #TODO
          session[:on] = false
        else
          data = '{"command":{"address":"/api/newdeveloper/lights/3/state","method":"PUT","body":{"on":true}}}' #TODO
          session[:on] = true
        end
        light = transmit(url,"put",data)
        pp light
        "aa"
      else
        "not ip "
        redirect "/portal"
      end
    end
  end
end
