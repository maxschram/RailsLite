
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
