class Admin::MediasController < ApplicationController
  before_action :set_note, only: [ :show, :edit, :update, :destroy ]

  def index
    @medias = Media.search_and_order params[:search], params[:page]
  end

  def new
    @media = Media.new
  end

  def edit
  end

  def update
    if @media.update(media_params)
      redirect_to admin_medias_path, notice: 'Media updated'
    else
      flash[:alert] = "Media couldn't be updated."
      render :edit
    end
  end

  def create
    @media = Media.create exhibit_params
    if @media
      redirect_to admin_medias_path, notice: 'Media created'
    else
      flash[:alert] = "Media couldn't be created"
      render :new
    end
  end

  def destroy
    if @media.destroy
      redirect_to admin_medias_path, notice: 'Media destroyed'
    else
      flash[:alert] = "Media couldn't be destroyed"
      redirect_to admin_users_path
    end
  end

  private

  def set_note
    @media = Media.find(params[:id])
  rescue
    flash[:alert] = "The note with an id of #{params[:id]} doesn't exist."
    redirect_to admin_medias_path
  end

  def exhibit_params
    params.require(:media).permit :name, :embed
  end
end
