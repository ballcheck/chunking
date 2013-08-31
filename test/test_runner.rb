require 'test/unit'
require 'mocha/setup'

Dir.glob( File.expand_path( "../unit/chunking/**/*.rb", __FILE__ ), &method( :load ) )
require File.expand_path( "../../lib/chunking/chunking", __FILE__ )
