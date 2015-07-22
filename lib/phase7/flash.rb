require 'json'
require 'webrick'

module Phase7
  class Flash
    def initialize(req)
      cookie = req.cookies.find{ |c| c.name == "flash" } if req
      if cookie
        @store = JSON.parse(cookie.value)
      else
        @store = {}
      end
    end

    def [](key)
      now[key] || store[key]
    end

    def []=(key, value)
      store[key] = value
    end

    def now
      @now ||= FlashNow.new
    end

    def store_flash(res)
      res.cookies << WEBrick::Cookie.new("flash", store.to_json)
    end

    def clear_flash(res)

    end

    private
    attr_reader :store, :store_now
  end

  class FlashNow < Flash
    def initialize
      super(nil)
    end

    def store_session(*args)
      raise "Can't store flash.now"
    end

    def [](key)
      store[key]
    end

    def []=(key, val)
      store[key] = val
    end

    def now
      raise
    end
  end
end
