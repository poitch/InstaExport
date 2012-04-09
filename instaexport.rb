require 'rubygems'
require 'sinatra'
require 'instagram'
require 'open-uri'
require 'tmpdir'
require 'zip/zip'
require 'zip/zipfilesystem'
require 'yaml'

CALLBACK_URL = "http://localhost:4567/oauth/callback"

if !File.exists?(ENV['HOME']+'/.instaexport.yaml') 
    puts "Please create #{ENV['HOME']}/.instaexport.yaml"
    exit
end

def config
    @config ||= YAML.load_file(ENV['HOME'] + "/.instaexport.yaml")
end

Instagram.configure do |cfg|
    cfg.client_id = config[:instagram][:client_id] 
    cfg.client_secret = config[:instagram][:client_id]
end

enable :sessions

get "/" do
  '<a href="/oauth/connect">Connect with Instagram</a>'
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = response.access_token
  puts "Access Token: #{session[:access_token]}"
  redirect "/feed"
end

get "/feed" do
  client = Instagram.client(:access_token => session[:access_token])
  user = client.user

  html = "<h1>#{user.username}'s recent photos</h1><br/>"
  html << "<a href='/export'>Export</a><br/>"
  for media_item in client.user_recent_media(:count => 100000)
    html << "<img width=\"150\" height=\"150\" src='#{media_item.images.thumbnail.url}'>"


    # media_item.tags
    # media_item.location.{latitude|name|longitude}
    # media_item.created_time
    # media_item.images.standard_resolution.url
    # media_item.caption.text
    # media_item.id
  end
  html
end

get "/export" do
    client = Instagram.client(:access_token => session[:access_token])

    filename = "Photos.zip"
    t = Tempfile.new("instaexport-#{Time.now}")
    Zip::ZipOutputStream.open(t.path) do |z|

        for media_item in client.user_recent_media(:count => 100000)
            z.put_next_entry("#{media_item.id}.jpg")
            z.print open(media_item.images.standard_resolution.url).read
        end
    end

    send_file t.path, :type => 'application/zip',
                        :disposition => 'attachment',
                        :filename => filename
end

