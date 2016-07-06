module ApiDoc
  module Generators
    class InstallGenerator < Rails::Generators::Base

      source_root File.dirname(__FILE__)

      desc "Copies locale files to your application and mounts the ApiDoc engine."

      def copy_locale
        copy_file File.join("templates", "en.yml"), "config/locales/api_doc.en.yml"
      end

      def add_api_doc_routes
        route 'mount ApiDoc::Engine => "/api_docs"'
      end

      def copy_index
        copy_file File.join("templates", "index.html.erb"), "app/views/api_doc/documents/index.html.erb"
      end

      initializer "rspec-api-doc.rb" do
         <<-EOCode
            # Rspec 3 does not tack the Rack response/request objects onto the metadata of the example
            # like Rspec 2 did. But this is needed for the api_doc gem to inspect the state of them and generate
            # docs based on what happened in the API interactions.
            class RSpec::Core::Example
              alias_method :run_after_example_without_response_payload, :run_after_example

              def run_after_example
                self.metadata[:response] = @example_group_instance.response
                run_after_example_without_response_payload
              end
            end
          EOCode
      end
    end
  end
end
