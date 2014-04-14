module Raddocs
  class App < Sinatra::Base
    helpers Sinatra::JSON
    set :root, File.join(File.dirname(__FILE__), "..")


    get "/*" do
      file = "#{docs_dir}/#{params[:splat][0]}.json"
      index = "#{docs_dir}/#{params[:splat][0]}/index.json"

      if File.exists?(file)
        file_content = File.read(file)
      elsif  File.exists?(index)
        file_content = File.read(index)
      else
        raise Sinatra::NotFound
      end


      example = JSON.parse(file_content)
      #example["parameters"] = Parameters.new(example["parameters"]).parse
      #haml :example, :locals => { :example => example }
      json example
    end

    not_found do
      "Example does not exist"
    end

    helpers do
      def link_to(name, link)
        %{<a href="#{url_location}#{link}">#{name}</a>}
      end

      def url_location
        "#{url_prefix}#{request.env["SCRIPT_NAME"]}"
      end

      def url_prefix
        url = Raddocs.configuration.url_prefix
        return '' if url.to_s.empty?
        url.start_with?('/') ? url : "/#{url}"
      end

      def api_name
        Raddocs.configuration.api_name
      end

      def css_files
        files = ["#{url_location}/codemirror.css", "#{url_location}/application.css"]

        if Raddocs.configuration.include_bootstrap
          files << "#{url_location}/bootstrap.min.css"
        end

        Dir.glob(File.join(docs_dir, "styles", "*.css")).each do |css_file|
          basename = Pathname.new(css_file).basename
          files << "#{url_location}/custom-css/#{basename}"
        end

        files.concat Array(Raddocs.configuration.external_css)

        files
      end
    end

    def docs_dir
      Raddocs.configuration.docs_dir
    end
  end
end
