$routes = Proc.new do
  get Regexp.new("^/$"), CatsController, :index
  get Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/new"), CatsController, :new
  post Regexp.new("^/cats$"), CatsController, :create
  post Regexp.new("^/cats/(?<id>\\d+)/destroy$"), CatsController, :destroy

  get Regexp.new("^/humans/(?<id>\\d+)"), HumansController, :show
  get Regexp.new("^/humans/new"), HumansController, :new
  post Regexp.new("^/humans$"), HumansController, :create
end
