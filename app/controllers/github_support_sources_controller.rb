class GithubSupportSourcesController < ApplicationController
  before_action :set_github_support_source, only: [:edit, :update, :destroy]

  # GET /github_support_sources/new
  def new
    @support_source = GithubSupportSource.new
  end

  # GET /github_support_sources/1/edit
  def edit
  end

  # POST /github_support_sources
  # POST /github_support_sources.json
  def create
    @support_source = GithubSupportSource.new(github_support_source_params)

    respond_to do |format|
      if @support_source.save
        format.html { redirect_to support_sources_path,
          notice: 'Support source was successfully created.' }
        format.json { render :show, status: :created,
          location: @support_source }
      else
        format.html { render :new }
        format.json { render json: @support_source.errors,
          status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /github_support_sources/1
  # PATCH/PUT /github_support_sources/1.json
  def update
    respond_to do |format|
      if @support_source.update(github_support_source_params)
        format.html { redirect_to edit_github_support_source_path(@support_source),
          notice: 'Support source was successfully updated.' }
        format.json { render :show, status: :ok, location: @support_source }
      else
        format.html { render :edit }
        format.json { render json: @support_source.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /github_support_sources/1
  # DELETE /github_support_sources/1.json
  def destroy
    @support_source.destroy
    respond_to do |format|
      format.html { redirect_to support_sources_url, notice: 'Support source was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_github_support_source
    @support_source = current_user.github_support_sources.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def github_support_source_params
    params.require(:github_support_source).
      permit(:name, :github_owner_and_repo).
      merge(user: current_user)
  end
end
