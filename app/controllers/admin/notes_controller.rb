class Admin::NotesController < Admin::BaseController
  before_action :set_note, only: [ :show, :edit, :update, :destroy ]

  def index
    @notes = Note.search_and_order params[:search], params[:page]
  end

  def new
    @note = Note.new
  end

  def edit
  end

  def update
    if @note.update(note_params)
      redirect_to admin_notes_path, notice: 'Note updated'
    else
      flash[:alert] = "Note couldn't be updated."
      render :edit
    end
  end

  def create
    @note = Note.create exhibit_params
    if @note
      redirect_to admin_notes_path, notice: 'Note created'
    else
      flash[:alert] = "Note couldn't be created"
      render :new
    end
  end

  def destroy
    if @note.destroy
      redirect_to admin_notes_path, notice: 'Note destroyed'
    else
      flash[:alert] = "Note couldn't be destroyed"
      redirect_to admin_users_path
    end
  end

  private

  def set_note
    @note = Note.find(params[:id])
  rescue
    flash[:alert] = "The note with an id of #{params[:id]} doesn't exist."
    redirect_to admin_notes_path
  end

  def exhibit_params
    params.require(:note).permit :body, :author
  end
end
