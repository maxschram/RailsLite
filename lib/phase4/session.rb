require 'json'
require 'webrick'

module Phase4
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
      res.cookies << WEBrick::Cookie.new("_rails_lite_app", store.to_json)
    end

    private
    attr_reader :store
  end
end
