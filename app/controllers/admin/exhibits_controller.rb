class Admin::ExhibitsController < Admin::BaseController
  before_action :set_exhibit, only: [ :show, :edit, :update, :destroy ]

  def index
    @exhibits = Exhibit.search_and_order params[:search], params[:page]
  end

  def new
    @exhibit = Exhibit.new
  end

  def edit
  end

  def update
    if @exhibit.update(exhibit_params)
      redirect_to admin_exhibits_path, notice: 'Exhibit updated'
    else
      flash[:alert] = "Exhibit couldn't be updated."
      render :edit
    end
  end

  def create
    @exhibit = Exhibit.create exhibit_params
    if @exhibit
      redirect_to admin_exhibits_path, notice: 'Exhibit created'
    else
      flash[:alert] = "Exhibit couldn't be created"
      render :new
    end
  end

  def destroy
    if @exhibit.destroy
      redirect_to admin_exhibits_path, notice: 'Exhibit destroyed'
    else
      flash[:alert] = "Exhibit couldn't be destroyed"
      redirect_to admin_users_path
    end
  end

  private

  def set_exhibit
    @exhibit = Exhibit.find(params[:id])
  rescue
    flash[:alert] = "The exhibit with an id of #{params[:id]} doesn't exist."
    redirect_to admin_exhibits_path
  end

  def exhibit_params
    params.require(:exhibit).permit :subtype,
                                    :name,
                                    :author,
                                    :year,
                                    :materials,
                                    :size,
                                    :owner,
                                    :image
  end
end
