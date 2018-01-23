require_relative '../authrocket'

%w(engine).each do |f|
  require_relative "rails/#{f}"
end
