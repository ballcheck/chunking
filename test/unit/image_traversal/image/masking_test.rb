require File.expand_path( "../../test_helper.rb", __FILE__ )
module ImageTraversal
  class MaskingTest < TestCase
    def build_img( *args )
      ImageTraversal.image_adapter_class.factory( *args )
    end

    def test_should_create_mask
      x, y = (1..100).to_a.sample( 2 )
      img = build_img( x, y )
      mask = img.create_mask

      # same size
      assert_equal [ x, y ], [ img.size( :x ), img.size( :y ) ]

      # blank
      y.times do |row_ind|
        x.times do |px_ind|
          assert_equal Palette.white, img.get_pixel_colour( x, y )
        end
      end
    end

    def test_should_apply_mask
      img = build_img( 1, 1 )
      mask = img.create_mask
      opacity = stub( "opacity" )
      new_img = stub( "new_img" )

      # calls adapter method :disolve
      img.expects( :dissolve ).once.with( mask.base_image, opacity, 1 ).returns( new_img )
      assert_equal new_img, img.apply_mask( mask, opacity )
    end
  end
end
