require_relative '../phase7/controller_base'

module Phase8
  class ControllerBase < Phase7::ControllerBase

    def form_authenticity_token
      token = generate_authenticity_token
      res.cookies << WEBrick::Cookie.new("authenticity_token", token)
      token
    end

    def invoke_action(name)
      if protect_from_forgery? && req.request_method != "GET"
        check_authenticity_token
      else
        form_authenticity_token
      end
      super
    end

    protected

    def self.protect_from_forgery
      @@protect_from_forgery = true
    end

    private

    def protect_from_forgery?
      @@protect_from_forgery
    end

    def check_authenticity_token
      cookie = req.cookies.find{ |c| c.name == "authenticity_token" }
      unless cookie && cookie.value == params["authenticity_token"]
        raise "Invalid authenticity_token"
      end
    end

    def generate_authenticity_token
      SecureRandom::urlsafe_base64(16)
    end
  end
end
