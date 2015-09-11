require 'webrick'
require_relative '../lib/phase7/controller_base'
require_relative '../lib/phase6/router'


# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html

class MyController < Phase7::ControllerBase
  def flashing
    flash["message"] = "Hello"
    render :flashing
  end
end

router = Phase6::Router.new
router.draw do
  get Regexp.new("^/flashing$"), MyController, :flashing
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
