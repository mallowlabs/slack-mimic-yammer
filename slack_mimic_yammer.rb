require 'sinatra'
require 'json'
require 'active_support'
require 'active_support/core_ext'

class SlackMimicYammer < Sinatra::Base
  before do
    content_type :json
  end

  post '/services/:group_id/:dummy1/:dummy2' do
    call env.merge('PATH_INFO' => '/services/:group_id')
  end

  post '/services/:group_id' do
    access_token = ENV['YAMMER_ACCESS_TOKEN']
    unless access_token
      status 503
      return {error: 'You need to set YAMMER_ACCESS_TOKEN'}.to_json
    end

    json = JSON.parse(params['payload'])
    body = json["text"]
    if body.blank?
      attachemnt = json["attachments"][0] rescue nil
      if attachemnt
        body = attachemnt["pretext"] || attachemnt["text"] || attachemnt["fallback"]
      end
    end

    if body.blank?
      status 500
      return {error: 'Text must be set'}.to_json
    end

    body, og_url, og_title = parse_body(body)

    group_id = params[:group_id]

    begin
      post_to_yammer(access_token, group_id, body, og_url, og_title)

      status 200
      {status: 'ok'}.to_json
    rescue => error
      status 500
      {error: error}.to_json
    end
  end

  private

  def parse_body(body)
    og_url = nil
    og_title = nil
    body = body.gsub(/<(.+?)>/) do |ref|
      if $1.index('://')  # link
        if $1.index('|')
          og_url, og_title = $1.split('|', 2)
          og_url
        else
          og_url = $1
          og_title = nil
          $1
        end
      elsif $1.start_with?("#") # channel
        $1
      else # other
        ref
      end
    end
    [body, og_url, og_title]
  end

  def post_to_yammer(access_token, group_id, body, og_url = nil, og_title = nil)
    begin
      timeout 10 do
        https = Net::HTTP.new("www.yammer.com", 443)
        https.use_ssl = true
        res = https.start do |conn|
          conn.post("/api/v1/messages.json", URI.encode_www_form({
            group_id: group_id,
            og_url: og_url,
            og_title: og_title,
            body: body
          }), {'Authorization' => "Bearer #{access_token}"})
        end
      end
    rescue Timeout::Error
      warn 'yammer -- timed out'
    end
  end

end
