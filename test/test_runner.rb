require File.expand_path( "../test_helper", __FILE__ )
Dir.glob( File.expand_path( "../unit/**/*.rb", __FILE__ ), &method( :load ) )
Dir.glob( File.expand_path( "../../lib/chunking/**/*.rb", __FILE__ ), &method( :load ) )
