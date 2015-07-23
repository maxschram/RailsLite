class CatsController < ControllerBase
  protect_from_forgery

  def index
    if params["id"]
      @human = Human.find(params["id"].to_i)
      @cats = @human.cats
    else
      @cats = Cat.all
    end
    render :index
  end

  def new
    @cat = Cat.new
    render :new
  end

  def destroy
    @cat = Cat.find(params["id"].to_i)
    @cat.destroy
    redirect_to "/cats"
  end

  def edit
    @cat = Cat.find(params["id"].to_i)
    render :edit
  end

  def update
    @cat = Cat.find(params["id"].to_i)

    @cat.name = params["cat"]["name"]
    @cat.owner_id = params["cat"]["owner_id"].to_i

    if @cat.update
      redirect_to "/cats/#{@cat.id}"
    else
      flash[:errors] = @cat.errors.full_messages
      render :edit
    end
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
