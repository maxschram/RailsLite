require 'webrick'
require_relative '../lib/phase7/controller_base'
require_relative '../lib/phase6/router'
require 'byebug'


# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html

class MyController < Phase7::ControllerBase
  def flashing
    render :flashing
  end

  def add_flash
    flash["message"] = "This is a flash message"
    render :show_flashing
  end

  def add_flash_now
    flash.now["message"] = "This is a flash message"
    render :show_flashing
  end

  def add_flash_redirect
    flash["message"] = "This is a flash message"
    redirect_to "show_flashing"
  end

  def add_flash_now_redirect
    flash.now["message"] = "This is a flash message"
    redirect_to "show_flashing"
  end

  def show_flashing
    render :show_flashing
  end
end

router = Phase6::Router.new
router.draw do
  get Regexp.new("^/flashing$"), MyController, :flashing
  get Regexp.new("^/add_flash$"), MyController, :add_flash
  get Regexp.new("^/add_flash_now$"), MyController, :add_flash_now
  get Regexp.new("^/add_flash_redirect$"), MyController, :add_flash_redirect
  get Regexp.new("^/add_flash_now_redirect$"), MyController, :add_flash_now_redirect
  get Regexp.new("^/show_flashing$"), MyController, :show_flashing
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
