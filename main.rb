require "./common/jsonpost.rb"

obj = JsonPost.new

obj.requestURL("POST","api_name0",{'email' => "hoge@hoge.co.jp", 'password' => "12345"})
obj.requestURL("GET","api_name1",nil)
obj.requestURL("GET","api_name3",{'id' => "205169", 'timestamp' => "1455675252"})
obj.requestURL("POST-JSON","api_name4",{'roups' => {"8155" => 581977}})
