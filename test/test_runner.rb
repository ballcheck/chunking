require File.expand_path( "../unit/image_traversal/test_helper.rb", __FILE__ )
Dir.glob( File.expand_path( "../unit/image_traversal/**/*.rb", __FILE__ ), &method( :load ) )
