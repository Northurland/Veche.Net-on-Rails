require_relative 'regular'

module Morphology
  module Tunisian
    module Nouns
      module Feminine
        module CompoundWithItic
          include Feminine::Regular

          def subtype
            "Compound with Ític"
          end

          private

          def singular
            "vec" + (no_hyphen? ? "" : "-") + strong + "e"
          end

          def plural
            "vecs" + (no_hyphen? ? "" : "-") + strong + "s"
          end
        end
      end
    end
  end
end
