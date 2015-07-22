require 'webrick'
require_relative '../lib/controller_base'
require_relative '../lib/flash'
require_relative '../lib/params'
require_relative '../lib/router'
require_relative '../lib/session'
require "active_support"
require 'active_support/core_ext'



# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html

class MyController < ControllerBase
  protect_from_forgery

  def csrf
    render :csrf
  end

  def submit
    render :csrf
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/$"), MyController, :csrf
  post Regexp.new("^/$"), MyController, :submit
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
