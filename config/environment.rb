# frozen_string_literal: true
# Load the Rails application.
require_relative "application"

# load test_set.rb
app_test = File.join(Rails.root, "config", "test_set.rb")
load(app_test) if File.exist?(app_test)

# Initialize the Rails application.
Rails.application.initialize!
