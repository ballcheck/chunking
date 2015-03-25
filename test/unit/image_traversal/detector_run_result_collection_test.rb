require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal
  class DetectorRunResultCollectionTest < TestCase

    def test_should_annotate
      # Given
      # an image that creates mask.
      image = build_image
      mask = build_image
      image.stubs( :create_mask => mask )

      # a collection of results
      result_collection = Detector::Run::ResultCollection.new
      (2..10).to_a.sample.times do |i|
        result = build_result
        # ensure #annotate! is called once for each result
        result.expects( :annotate! ).once.with( mask )
        result_collection << result
      end

      # Then
      result_collection.annotate( image )
    end

  end
end
