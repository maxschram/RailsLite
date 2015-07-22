
class ControllerBase
  attr_reader :req, :res, :params

  # setup the controller
  def initialize(req, res, route_params = {})
    @params = Params.new(req, route_params)
    @req = req
    @res = res
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    already_built_response
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(res)
  end

  def render(template_name)
    template_path = "views/#{controller_name}/#{template_name}.html.erb"
    template = ERB.new(File.read(template_path))
    content = template.result(binding)
    render_content(content, "text/html")
  end

  def redirect_to(url)
    raise "Cannot render twice" if already_built_response?
    res.status = 302
    res["location"] = url
    self.already_built_response = true
    session.store_session(res)
    flash.store_flash(res)
  end

  def render_content(content, content_type)
    raise "Cannot render twice" if already_built_response?
    res.content_type = content_type
    res.body = content
    self.already_built_response = true
    session.store_session(res)
    flash.store_flash(res)
  end

  # method exposing a `Flash` object
  def flash
    @flash ||= Flash.new(req)
  end

  def form_authenticity_token
    token = generate_authenticity_token
    cookie = WEBrick::Cookie.new("authenticity_token", token)
    cookie.path = "/"
    res.cookies << cookie
    token
  end

  def invoke_action(name)
    if protect_from_forgery? && req.request_method != "GET"
      check_authenticity_token
    else
      form_authenticity_token
    end
    send(name)
    render(name) unless already_built_response?
  end

  protected

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  private

  attr_accessor :already_built_response
  attr_writer :req, :res

  def controller_name
    self.class.to_s.underscore
  end

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
    SecureRandom.urlsafe_base64(16)
  end
end
