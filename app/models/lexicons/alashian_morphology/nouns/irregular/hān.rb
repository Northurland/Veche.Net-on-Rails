require_relative '../masculine/regular'

module Morphology
  module Alashian
    module Nouns
      module Irregular
        module Han
          include Masculine::Regular

          def declension
            "Masculine Noun"
          end

          def subtype
            "Irregular"
          end

          def _absolute_plural
            ["ηων", "hān"]
          end

          def _construct_plural
            _absolute_plural
          end
        end
      end
    end
  end
end
