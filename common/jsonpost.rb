# coding: utf-8
require 'net/https'
require 'json'

class JsonPost

  @@sessionId = ""
  @@host = "https://hoge.com/api/"

  def initialize()
      @@sessionId = initLogin()
  end

  # login.jsonファイルからセッションIDを取得する
  def initLogin
    jsonLogin = nil
    file = File.open("./common/login.json", "r")
    file.each do |line|
      jsonLogin = JSON.parse(line)
    end
    file.close
    return jsonLogin["data"]["login_info"]["session_id"]
  end

  # リクエスト送信
  def requestURL(flag,url,parameter)
    begin

      File.open("output/"+url+".md", "w") do |file|

          file.puts("# "+url)
          file.puts("\n")
          file.puts("## Url\n")
          file.puts(@@host+url+"\n")
          file.puts("\n")
          file.puts("## Type\n")
          file.puts(flag+"\n")
          file.puts("\n")
          file.puts("## Parameter\n")

          # is_loginでログイン状態を取得する
          uri = URI.parse(@@host+url)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.set_debug_output $stderr

          # リクエスト送信
          if flag.eql?("GET")
            _parameter = ""
            if !parameter.nil?
              parameter.each{|key, value|
                if _parameter == ""
                  _parameter <<  "?" + key + "=" + value
                else
                  _parameter <<  "&" + key + "=" + value
                end
              }
            end
            req = Net::HTTP::Get.new(uri.path+_parameter)
            req['Cookie'] = "gringid=#{@@sessionId};"
            req['Referer'] = 'http://hoge.com/hogehoge'
            req['X-Requested-With'] = 'XMLHttpRequest'
          elsif flag.eql?("POST-JSON")
            req = Net::HTTP::Post.new(uri.path)
            req['Cookie'] = "gringid=#{@@sessionId};"
            req['Referer'] = 'http://hoge.com/hogehoge'
            req['X-Requested-With'] = 'XMLHttpRequest'
            req["Content-Type"] = "application/json"
            if !parameter.nil?
              req.body=parameter.to_json
            end
          else
            req = Net::HTTP::Post.new(uri.path)
            req['Cookie'] = "gringid=#{@@sessionId};"
            req['Referer'] = 'http://hoge.com/hogehoge'
            req['X-Requested-With'] = 'XMLHttpRequest'
            if !parameter.nil?
              req.set_form_data(parameter)
            end

          end

          res = http.request(req)

          if parameter.nil?
            file.puts("not parameter"+"\n")
            file.puts("\n")
          else
            file.puts("|Key|Type|requires|discription|"+"\n")
            file.puts("|:---|---:|:---:|"+"\n")
            parameter.each{|key, value|
              file.puts("|"+key+"|"+value.class.to_s+"|"+"○"+"|"+"-"+"|"+"\n")
            }
            file.puts("\n")
          end

          # レスポンス処理
          if res.code == '200'

            #jsonLogin = JSON.parse(res.body)
            #islogin = jsonLogin["data"]["login_info"]["is_login"]
            # セッション切れの場合エラーで終了
            #if islogin then
              file.puts("## Respons\n")
              file.puts("```json"+"\n")
              file.puts(res.body+"\n")
              file.puts("```"+"\n")
              file.puts("\n")

            #else
              #exit 3
            #end
          else
            puts "ERROR #{res.code} #{res.message}"
            exit res.code
          end

      end #file open
      #exit 0
    rescue SystemCallError => e
      puts %Q(class=[#{e.class}] message=[#{e.message}])
      exit 2
    rescue IOError => e
      puts %Q(class=[#{e.class}] message=[#{e.message}])
      exit 1

    end #begin

  end

end
