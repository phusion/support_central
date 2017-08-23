class RssSupportSourcesController < ApplicationController
  before_action :set_rss_support_source, only: [:edit, :update, :destroy]

  # GET /rss_support_sources/new
  def new
    @support_source = RssSupportSource.new
  end

  # GET /rss_support_sources/1
  def show
    redirect_to action: :edit
  end

  # GET /rss_support_sources/1/edit
  def edit
  end

  # POST /rss_support_sources
  # POST /rss_support_sources.json
  def create
    @support_source = RssSupportSource.new(rss_support_source_params)

    respond_to do |format|
      if @support_source.save
        format.html { redirect_to support_sources_path,
          notice: 'Support source was successfully created.' }
        format.json { render :show, status: :created, location: @support_source }
      else
        format.html { render :new }
        format.json { render json: @support_source.errors,
          status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rss_support_sources/1
  # PATCH/PUT /rss_support_sources/1.json
  def update
    respond_to do |format|
      if @support_source.update(rss_support_source_params)
        format.html { redirect_to @support_source,
          notice: 'Support source was successfully updated.' }
        format.json { render :show, status: :ok, location: @support_source }
      else
        format.html { render :edit }
        format.json { render json: @support_source.errors,
          status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rss_support_sources/1
  # DELETE /rss_support_sources/1.json
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
  def set_rss_support_source
    @support_source = current_user.rss_support_sources.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def rss_support_source_params
    params.require(:rss_support_source).
      permit(:name, :rss_url).
      merge(user: current_user)
  end
end
