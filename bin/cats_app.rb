require 'webrick'
require_relative '../lib/controller_base'
require_relative '../lib/flash'
require_relative '../lib/params'
require_relative '../lib/router'
require_relative '../lib/session'
require_relative '../lib/activerecord/sql_object'
require "active_support"
require 'active_support/core_ext'
require 'byebug'



# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html

class Cat < SQLObject
  belongs_to :human, foreign_key: :owner_id
  finalize!
end

class Human < SQLObject
  self.table_name = 'humans'

  has_many :cats, foreign_key: :owner_id
  finalize!
end

class CatsController < ControllerBase
  protect_from_forgery

  def index
    @cats = Cat.all
    render :index
  end

  def new
    @cat = Cat.new
    render :new
  end

  def create
    cat = Cat.new(name: params["cat"]["name"],
                  owner_id: params["cat"]["owner_id"].to_i )
    if cat.save
      redirect_to "/cats/#{cat.id}"
    else
      flash[:errors] = cat.errors.full_messages
      render :new
    end
  end

  def show
    @cat = Cat.find(params["id"].to_i)
    render :show
  end
end

class HumansController < ControllerBase
  protect_from_forgery

  def new
    @human = Human.new
    render :new
  end

  def create
    human = Human.new(fname: params["human"]["fname"],
                      lname: params["human"]["lname"])

    if human.save
      redirect_to "/humans/#{human.id}"
    else
      flash[:errors] = human.errors.full_messages
      render :new
    end
  end

  def show
    @human = Human.find(params["id"].to_i)
    render :show
  end
end

router = Router.new
router.draw do
  get Regexp.new("^/$"), CatsController, :index
  get Regexp.new("^/cats/(?<id>\\d+)"), CatsController, :show
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/new"), CatsController, :new
  post Regexp.new("^/cats$"), CatsController, :create

  get Regexp.new("^/humans/(?<id>\\d+)"), HumansController, :show
  get Regexp.new("^/humans/new"), HumansController, :new
  post Regexp.new("^/humans$"), HumansController, :create
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
