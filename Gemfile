source 'https://rubygems.org'
ruby '2.1.1'

gem 'rails', '4.1.4'
gem 'psych', '~> 2.0.3'

# PostgreSQL
gem 'pg', '~> 0.17.0'

# Postgis
gem 'activerecord-postgis-adapter', '~> 2.2.0'
# Has been removed for some time?
# gem 'squeel', git: 'https://github.com/gtimti/squeel.git'  # nybex and kiela forks were also used

# rgeo support
gem 'ffi-geos'
gem 'rgeo-shapefile'
gem 'rgeo-geojson'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 2.4'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 3.1.1'
gem 'jquery-ui-rails'

# Turbolinks makes following links in your web application faster.
# Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
gem 'jquery-turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
gem 'chronic', '~> 0.10'

gem 'awesome_nested_set',
    git: 'https://github.com/collectiveidea/awesome_nested_set.git'
#  tag: 'v3.0.0.rc.5', 

# BibTex handling
gem 'bibtex-ruby', '~> 4.0.3'
gem 'citeproc-ruby'
#gem 'citeproc'
gem 'csl-styles'

# Pagination
gem 'kaminari'

# File upload manager & image processor
gem 'paperclip', '~> 4.2'

# Ordering records
gem 'acts_as_list'

# Versioning
gem 'paper_trail', '~> 3.0.0'

# DwC-A archive handling 
gem 'dwc-archive', '~> 0.9.11'
gem 'biodiversity', '3.1.4' # Workaround rails' treetop dependency incompatibility with dwc-archive

gem 'validates_timeliness', '~> 3.0.14'

# Password encryption
gem 'bcrypt-ruby', '~> 3.1.5'

# API view template engine
gem 'rabl'

gem 'rmagick', '~> 2.13.2'

# Generate fake data: names, addresses, phone numbers, etc.
gem 'faker', '~> 1.4.2' # tutorial used 1.1.2

group :test, :development do
  gem 'rspec-rails', '~> 3.0' #  
  gem 'rspec-activemodel-mocks', '~> 1.0.1'
  gem 'inch'
  gem 'byebug', {}.merge(ENV['RM_INFO'] ? {require: false} : {})
  gem 'awesome_print'
  gem 'factory_girl_rails', '~> 4.0'
end

group :development do
  gem 'better_errors', '~> 2.0'
  gem 'binding_of_caller'
  gem 'spring', '~> 1.1.3'
  gem 'spring-commands-rspec', '~> 1.0.2'
  gem 'guard-rspec', '~> 4.3.1', require: false
end

group :doc do
  gem 'sdoc', require: false # bundle exec rake doc:rails generates the API under doc/api.
end

group :test do
  gem 'rspec', '~> 3.0'
  gem 'coveralls', '~> 0.7', require: false
  gem 'capybara', '~> 2.1'
  gem 'timecop', '~> 0.7.1'
  gem 'webmock', '~> 1.18.0'
  gem 'vcr', '~> 2.9.2'
end

