module Panel
  module Blog
    class TemplatesController < BlogController
      before_action :set_template, only: %i[show edit update destroy]

      def index
        @templates = Template.all
      end

      def show
      end

      def new
        @template = Template.new
      end

      def create
        @template = Template.new(template_params)

        if @template.save
          redirect_to panel_blog_template_path(@template), notice: t(".success")
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
      end

      def update
        if @template.update(template_params)
          redirect_to panel_blog_template_path(@template), notice: t(".updated")
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @template.destroy
        redirect_to panel_blog_templates_path, notice: t(".deleted")
      end

      private

      def set_template
        @template = Template.find(params[:id])
      end

      def template_params
        params.require(:template).permit(:name, :markup)
      end
    end
  end
end
