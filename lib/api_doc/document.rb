module ApiDoc
  class Document

    def initialize(example, options = {})
      @response = example.metadata[:response]
      @request = @response.request

      @params = @request.env['action_dispatch.request.parameters']
      @path_parameters = @request.env['action_dispatch.request.path_parameters']

      options.reverse_merge!(path: File.join(@params["controller"], @params["action"]))
      options.reverse_merge!(slug: options[:path].parameterize)
      @options = options
    end

    def request_json
      body = @request.env['rack.input']
      if body.present?
        body.rewind
        # ret = URI.unescape(body.read)
        ret = body.read
        if ret.present?
          return JSON.pretty_generate(Rack::Utils.parse_nested_query(CGI.unescape(ret)))
        else
          return "// No request body necessary."
        end
      else
        return "// No request body necessary."
      end
    end

    def request_params
      CGI.unescape(@params.except(*@path_parameters.keys, "format").to_query)
    end

    def response_json
      body = @response.body.strip
      if body.present?
        return JSON.pretty_generate(JSON.parse(body))
      else
        return "// No response body returned."
      end
    end

    def response_headers
      @response.headers.map {|k, v| "#{k}: #{v.to_json}"}.join("\n")
    end

    def request_headers
      unless @request_headers
        @request_headers = {}
        @request.headers.each do |key, value|
          unless key.match(/^(action_dispatch|rack)/)
            @request_headers[key] = value
          end
        end
      end
      return @request_headers.map {|k, v| "'#{k}': #{v.to_json}"}.join("\n")
    end

    def generate!
      template = ERB.new(File.read(File.join(File.dirname(__FILE__), "templates", "page.html.erb")))
      html = template.result(binding)
      # puts html
      dir_path = File.join([ApiDoc::Config.view_path, File.dirname(@options[:path]).split("/")].flatten)
      # puts "dir_path: #{dir_path.inspect}"
      FileUtils.mkdir_p(dir_path)
      name = [@request.method, File.basename(@options[:path]), @options[:name].try(:gsub, " ", "_"), "(#{@response.status})"]
      name.compact!
      name = name.join("_")
      # File.open(File.join(dir_path, "#{name.join("_").gsub(" ", "_")}.html.erb"), 'w') do |f|

      # name = "#{@request.method}_#{File.basename(@options[:path])}_(#{@response.status})"
      # puts "name: #{name.inspect}"
      File.open(File.join(dir_path, "#{name}.html.erb"), 'w') do |f|
        f.write html
      end
    end

  end
end
