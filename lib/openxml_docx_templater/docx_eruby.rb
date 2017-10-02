# frozen_string_literal: true

module OpenxmlDocxTemplater
  class DocxEruby
    include Debug
    #original pattern {% %} destroy file with images
    # EMBEDDED_PATTERN = /\{%([=%]+)?(.*?)-?%\}/m
    #new pattern {{% %}} allow filw with images
    EMBEDDED_PATTERN = /\{{%([=%]+)?(.*?)-?%\}}/m

    def initialize(template)
      @src = convert template
      return unless debug?
      File.open(debug_file_path, 'w') do |f|
        f << @src
      end
    end

    def evaluate(context)
      eval(@src, context)
    end

    private

    def convert(template)
      src = "_buf = '';"
      buffer = []

      template.each_node do |node, _type|
        buffer << process_instruction(node)
        buffer.flatten!
      end

      buffer.each { |line| src += line.to_buf }
      src += "\n_buf.to_s\n"
    end

    def process_instruction(text)
      pos = 0
      src = []

      text.scan(EMBEDDED_PATTERN) do |indicator, code|
        m = Regexp.last_match
        middle = text[pos...m.begin(0)]
        pos = m.end(0)
        src << Line.text(middle) unless middle.empty?

        if !indicator            # <% %>
          src << Line.code(code)
        elsif indicator == '='   # <%= %>
          src << Line.string(code)
        elsif indicator == '%'   # <%% %>
          src << Line.literal(code)
        end
      end

      rest = pos.zero? ? text : text[pos..-1]

      src << Line.text(rest) unless rest.nil? || rest.empty?
      src
    end
  end
end
