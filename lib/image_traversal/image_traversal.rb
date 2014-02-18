# so we can require everything in one go
require File.expand_path( "../detector", __FILE__ )
require File.expand_path( "../image/adapter_magick_image", __FILE__ )

module ImageTraversal
  def self.image_adapter_class
    Image::AdapterMagickImage
  end
end
