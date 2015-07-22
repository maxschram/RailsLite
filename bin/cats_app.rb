require 'webrick'
require_relative '../lib/manifest'
require_relative '../config/routes'
require_relative '../app/controllers/controller_manifest'
require_relative '../app/models/model_manifest'
require "active_support"
require 'active_support/core_ext'
require 'byebug'



# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html

router = Router.new
router.draw &$routes

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
  if route
    puts "\n#{route.controller_class}##{route.action_name}"
  else
    puts "route not found"
  end
end

trap('INT') { server.shutdown }
server.start
