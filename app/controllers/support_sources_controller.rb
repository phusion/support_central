class SupportSourcesController < ApplicationController
  before_action :set_support_source, only: [:edit, :destroy]

  # GET /support_sources
  # GET /support_sources.json
  def index
    @support_sources = SupportSource.all
  end

  # GET /support_sources/new
  def new
  end

  # GET /support_sources/1/edit
  def edit
    # Redirect to type-specific controller
    redirect_to [:edit, @support_source]
  end

  # DELETE /support_sources/1
  # DELETE /support_sources/1.json
  def destroy
    @support_source.destroy
    respond_to do |format|
      format.html { redirect_to support_sources_url,
        notice: 'Support source was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_support_source
    @support_source = current_user.support_sources.find(params[:id])
  end
end
