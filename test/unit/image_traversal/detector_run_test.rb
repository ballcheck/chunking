require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal
  class DetectorRunTest < TestCase
    
    def test_method_add_results
      # a run with no results.
      run = Detector::Run.new
      assert_equal [], run.results

      # results to be added.
      result_a = build_result
      result_b = build_result

      # then...
      run.add_result( result_a )
      assert_equal [ result_a ], run.results

      run.add_result( result_b )
      assert_equal [ result_a, result_b ], run.results
    end

    def test_method_add_results_should_increment_tolerance_counter_if_state_changed
      # a Run with zero tolerance_counter.
      run = Detector::Run.new
      assert_equal 0, run.send( :tolerance_counter )

      # add a result - should not increment counter.
      result_a = build_result( true )
      run.add_result( result_a )
      assert_equal 0, run.send( :tolerance_counter )

      # then...
      # if the result does not equal the very first result, increment counter.
      result_b = build_result( false )
      run.add_result( result_b )
      assert_equal 1, run.send( :tolerance_counter )
    end

    def test_should_annotate_results
      run = Detector::Run.new

      # an image that creates mask.
      image = build_image
      mask = build_image
      image.stubs( :create_mask => mask )

      # then...
      # create results expecting :annotate!
      (2..10).to_a.sample.times do |i|
        result = build_result
        result.expects( :annotate! ).with( mask )
        run.add_result( result )
      end

      # go
      run.annotate( image )
    end

  end
end
