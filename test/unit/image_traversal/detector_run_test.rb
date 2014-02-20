require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal
  class DetectorRunTest < TestCase
    
    def test_method_add_results
      run = Detector::Run.new
      result_a = Detector::Result.new
      result_b = Detector::Result.new

      assert_equal [], run.results

      run.add_result( result_a )
      assert_equal [ result_a ], run.results

      run.add_result( result_b )
      assert_equal [ result_a, result_b ], run.results
    end

    def test_method_add_results_should_increment_tolerance_counter
      run = Detector::Run.new
      result_a = Detector::Result.new( true )
      result_b = Detector::Result.new( false )

      assert_equal 0, run.send( :tolerance_counter )

      run.add_result( result_a )
      assert_equal 0, run.send( :tolerance_counter )

      # if the result does not equal the very first result, increment counter.
      run.add_result( result_b )
      assert_equal 1, run.send( :tolerance_counter )
    end

    def test_should_annotate_image
      mask = stub( "mask" )
      image = mock( "image", :create_mask => mask, :apply_mask => mask )

      run = Detector::Run.new

      # create n run.results, each one expecting :annotate!
      n = (2..10).to_a.sample
      n.times do |i|
        result = Detector::Result.new
        result.expects( :annotate! ).with( mask )
        run.add_result( result )
      end

      assert_equal n, run.results.count

      run.annotate( image )
    end

  end
end
