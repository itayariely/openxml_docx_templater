module OpenxmlDocxTemplater
  module Generator
    def render template_path, output_path = output_name(template_path)
      template = Template.new template_path, output_path
      template.process binding
    end

    private

    def output_name input
      if input =~ /(.+)\.docx\Z/
        "#{$1}_output.docx"
      else
        "#{input}_output.docxs"
      end
    end
  end
end