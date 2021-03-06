$routes = Proc.new do
  get Regexp.new("^/$"), CatsController, :index
  get Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/new$"), CatsController, :new
  post Regexp.new("^/cats$"), CatsController, :create
  delete Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :destroy
  get Regexp.new("^/cats/(?<id>\\d+)/edit$"), CatsController, :edit
  patch Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :update

  get Regexp.new("^/humans/(?<id>\\d+)$"), HumansController, :show
  get Regexp.new("^/humans/new$"), HumansController, :new
  post Regexp.new("^/humans$"), HumansController, :create

  get Regexp.new("^/humans/(?<id>\\d+)/cats$"), CatsController, :index
end
