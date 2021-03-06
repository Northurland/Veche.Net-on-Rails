require_relative 'regular'

module Morphology
  module Tunisian
    module Nouns
      module Feminine
        module InitialR
          include Feminine::Regular

          def subtype
            "Initial R"
          end

          def _indefinite_plural_construct
            "uist " + plural
          end

          def _definite_singular_absolute
            "il " + singular
          end

          def _definite_plural_absolute
            "lst " + plural
          end
        end
      end
    end
  end
end
