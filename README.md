# ApiDoc

A quick and easy way to generate pretty API documentation for a Rails application using your (Rspec) controller specs.

## Installation

Add this line to your application's Gemfile:

    gem 'api_doc'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install api_doc

### NOTE: Add this Monkeypatch for RSpec 3.+

The following "decoration" is needed to hang the Rack response object off the
example metadata before it's passed to the `after` hook callback. Rspec
apparently used to do this, but now it doesn't, and apidoc desperately needs
this to inspect all the HTTP interactions from Rack.

     class RSpec::Core::Example
       alias_method :run_after_example_without_response_payload, :run_after_example

       def run_after_example
         self.metadata[:response] = @example_group_instance.response
         run_after_example_without_response_payload
       end
     end

TODO: put that in a generator, and make the generator work (currently broken for Rails 4)


## Usage

Prepare your Rails project by running the generator inside your project:

    rails g api_doc:install

This will copy over the appropriate assets and mount the engine routes.

Next, add the following to your <code>spec/spec_helper.rb</spec>:

    require "api_doc/rspec"

Then tag each controller spec that you want to document like so:

    describe 'index' do
      it 'returns a list of questions', :api_doc => true do
        get :index
        response.status.should be(200)
      end
    end

Finally, run <code>rake api:doc</code> command and visit /api_docs to browse the generated documentation.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
