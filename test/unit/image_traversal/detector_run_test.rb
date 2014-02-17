require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal
  class DetectorRunTest < TestCase
    
    def test_should_add_results
      run = Detector::Run.new
      result_a = Detector::Result.new( true )
      result_b = Detector::Result.new( false )

      assert_equal [], run.results

      run.add_result( result_a )
      assert_equal [ result_a ], run.results

      run.add_result( result_b )
      assert_equal [ result_a, result_b ], run.results
    end

    def test_should_correctly_observe_tolerance
      run = Detector::Run.new

      tolerance = 1
      result_a = Detector::Result.new( true )
      result_b = Detector::Result.new( false )

      assert_equal [], run.results
      assert_equal false, run.tolerance_exceeded?( tolerance )

      run.add_result( result_a )
      assert_equal false, run.tolerance_exceeded?( tolerance )

      run.add_result( result_b )
      assert_equal false, run.tolerance_exceeded?( tolerance )

      run.add_result( result_a )
      assert_equal false, run.tolerance_exceeded?( tolerance )

      # when 2 are the same, tolerance is exceeded.
      run.add_result( result_b )
      assert_equal false, run.tolerance_exceeded?( tolerance )

      run.add_result( result_b )
      assert_equal true, run.tolerance_exceeded?( tolerance )
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
