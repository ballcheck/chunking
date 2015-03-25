module ImageTraversal
  class Detector
    class Run
      class ResultCollection < Array

        def annotate( image, opacity = 0.5 )
          mask = image.create_mask

          # draw results on mask
          each do |result|
            result.annotate!( mask )
          end

          image.apply_mask( mask, opacity )
        end

      end
    end
  end
end
