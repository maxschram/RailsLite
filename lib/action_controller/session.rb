require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    cookie = req.cookies.find{ |cookie| cookie.name == "_rails_lite_app" }
    if cookie
      @store = JSON.parse(cookie.value)
    else
      @store = {}
    end
  end

  def [](key)
    store[key]
  end

  def []=(key, val)
    store[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    cookie = WEBrick::Cookie.new("_rails_lite_app", store.to_json)
    cookie.path = "/"
    res.cookies << cookie
  end

  private
  attr_reader :store
end
