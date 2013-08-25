require File.expand_path( "../test_helper", __FILE__ )
Dir.glob( File.expand_path( "../unit/**/*.rb", __FILE__ ), &method( :load ) )
require Rails.root.to_s << "/lib/chunking/chunking"
