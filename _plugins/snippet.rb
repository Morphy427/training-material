# frozen_string_literal: true

require 'yaml'
require './_plugins/gtn'

module Jekyll
  module Tags
    # A custom tag {% snippet %} which behaves almost identically to {% include %}
    # Except that it will render the included file as a proper GTN Box
    class SnippetIncludeTag < IncludeTag
      def markdownify(text)
        @site.find_converter_instance(
          Jekyll::Converters::Markdown
        ).convert(text.to_s)
      end

      def get_icon(icon)
        if icon.start_with?('fa')
          %(<i class="#{icon}" aria-hidden="true"></i><span class="visually-hidden">#{@text}</span>)
        elsif icon.start_with?('ai')
          %(<i class="ai #{icon}" aria-hidden="true"></i><span class="visually-hidden">#{@text}</span>)
        end
      end

      def get_config(context)
        context.registers[:site].config['icon-tag']
      end

      def render(context)
        @site ||= context.registers[:site]

        file = render_variable(context) || @file
        validate_file_name(file)

        # This doesn't feel right, we should've been able to figure it out in
        # render_variable(context) but it's not clear why that doesn't work.
        begin
          @site.inclusions[file] ||= locate_include_file(file)
        rescue StandardError
          @site.inclusions[file] ||= locate_include_file(context[file])
        end

        inclusion = @site.inclusions[file]

        add_include_to_dependency(inclusion, context) if @site.config['incremental']

        context.stack do
          context['include'] = parse_params(context) if @params
          x = inclusion.render(context).to_s
          p = context['include']

          box_start = ''
          box_end = ''
          if x.slice(0, 3) == '---'
            metadata = YAML.safe_load(x)

            # allow overriding box type with include parameter ("none" to render without a box)
            box_type = if !p.nil? && p['box_type']
                         p['box_type']
                       else
                         metadata['box_type']
                       end

            # Allow overriding the title with an include parameter
            title = if !p.nil? && p['override_title']
                      p['override_title']
                    else
                      metadata['title']
                    end

            if context.registers[:page]&.key?('lang')
              lang = context.registers[:page].fetch('lang', 'en')
              lang = 'en' if lang.nil?
            end
            lang = 'en' if lang.nil?
            if (box_type != 'none') && !box_type.nil?
              _box_id, box_title = Gtn::Boxify.generate_title(box_type, title, lang,
                                                              context.registers[:page]['path'])
              box_start = "> #{box_title}"
              box_end = "\n{: .#{box_type}}"
            end
          end
          y = x.split("\n---\n", 2).last
          # if y =~ /contribute/
          # puts "=== step 1   ===\n#{y}\n\n"
          # end
          z = markdownify(y)
          # if z =~ /contribute/
          # puts "=== step 2   ===\n#{z}\n\n"
          # end
          if box_start != ''
            z = z.gsub(/\R/, "\n> ")
            # puts box_start+y+box_end
          end

          # if z =~ /contribute/
          # puts "=== step 3   ===\n#{z}\n\n"
          # puts "=== MARKDOWN ===\n#{box_start+z+box_end}\n\n"
          # puts "=== RENDERED ===\n#{markdownify(box_start+z+box_end)}\n\n"
          # end

          final_box_text = markdownify(box_start + z + box_end)
                           # Replace newlines inside of a PRE with <br>, so they don't get eaten during next one.
                           .gsub(%r{<(pre)[^>]*>(.*?)</\1>}m) { |m| m.gsub(/\n/, '<br>') }
                           # Strip out spaces or the boxes break, replace
                           # them with single spaces so e.g. newlines get collapsed into a space
                           # and don't merge words together that shouldn't be merged.
                           .gsub(/\R+/, ' ')
                           .gsub('<h3', '<h3 data-toc-skip')
          "<!--SNIPPET-->#{final_box_text}<!--END_SNIPPET-->"
        end
      end

      private

      def locate_include_file(file)
        @site.includes_load_paths.each do |dir|
          path = PathManager.join(dir, file)
          return Inclusion.new(@site, dir, file) if valid_include_file?(path, dir)
        end
        raise IOError, could_not_locate_message(file, @site.includes_load_paths, @site.safe)
      end

      def valid_include_file?(path, dir)
        File.file?(path) && !outside_scope?(path, dir)
      end

      def outside_scope?(path, dir)
        @site.safe && !realpath_prefixed_with?(path, dir)
      end

      def realpath_prefixed_with?(path, dir)
        File.realpath(path).start_with?(dir)
      rescue StandardError
        false
      end

      def add_include_to_dependency(inclusion, context)
        return unless context.registers[:page]&.key?('path')

        @site.regenerator.add_dependency(
          @site.in_source_dir(context.registers[:page]['path']),
          inclusion.path
        )
      end
    end
  end
end

Liquid::Template.register_tag('snippet', Jekyll::Tags::SnippetIncludeTag)

Jekyll::Hooks.register :pages, :post_render do |page|
  if page.output =~ /-title>/
    page.output = Gtn::Boxify.replace_elements(page.output, page.data.fetch('lang', 'en'), page.path)
  end
end
