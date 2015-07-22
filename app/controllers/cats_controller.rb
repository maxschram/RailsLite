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

  def destroy
    @cat = Cat.find(params["id"].to_i)
    @cat.destroy
    redirect_to "/cats"
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
