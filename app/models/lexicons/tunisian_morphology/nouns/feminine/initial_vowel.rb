require_relative 'regular'

module Morphology
  module Tunisian
    module Nouns
      module Feminine
        module InitialVowel
          include Feminine::Regular

          def subtype
            "Initial Vowel"
          end

          def _indefinite_singular_construct
            "un " + singular
          end

          def _definite_singular_absolute
            "l-" + singular
          end

          def _definite_plural_absolute
            "l-" + plural
          end
        end
      end
    end
  end
end
