module Morphology
  module Novegradian
    module Nouns
      module OStem
        module NeuterEndingNominative
          def declension
            "O (Third) Declension"
          end

          def subtype
            "Neuter Ending-Nominative"
          end

          def _nominative_singular
            [desinence + "о", desinence_transliterated + "ó"]
          end

          def _nominative_dual
            [stem + "и", stem_transliterated + "i"]
          end

          def _nominative_plural
            [desinence + "а", desinence_transliterated + "á"]
          end

          def _genitive_singular
            if stem_transliterated == desinence_transliterated
              # Vowelless roots
              [stem + "у", stem_transliterated + "ú"]
            else
              [stem + "у", stem_transliterated + "u"]
            end
          end

          def _genitive_dual
            [stem + "у", stem_transliterated + "u"]
          end

          def _genitive_plural
            [tertiary, tertiary_transliterated]
          end

          def _accusative_singular
            [desinence + "о", desinence_transliterated + "ó"]
          end

          def _accusative_dual
            [stem + "и", stem_transliterated + "i"]
          end

          def _accusative_plural
            [desinence + "а", desinence_transliterated + "á"]
          end

          def _dative_singular
            [desinence + "ом", desinence_transliterated + "óm"]
          end

          def _dative_dual
            [desinence + "ома", desinence_transliterated + "óma"]
          end

          def _dative_plural
            [desinence + "ам", desinence_transliterated + "ám"]
          end

          def _partitive_singular
            if stem =~ /к[^ь]?$/
              _genitive_singular
            else
              [stem + "ок", stem_transliterated + "ok"]
            end
          end

          def _partitive_dual
            [stem + "у", stem_transliterated + "u"]
          end

          def _partitive_plural
            [desinence + "оу", desinence_transliterated + "óu"]
          end

          def _locative_singular
            [desinence + "ѣ", desinence_transliterated + "ě́"]
          end

          def _locative_dual
            [stem + "у", stem_transliterated + "u"]
          end

          def _locative_plural
            [desinence + "ѣх", desinence_transliterated + "ě́h"]
          end

          def _lative_singular
            [desinence + "он", desinence_transliterated + "ón"]
          end

          def _lative_dual
            [stem + "и", stem_transliterated + "i"]
          end

          def _lative_plural
            [desinence + "и", desinence_transliterated + "í"]
          end
        end
      end
    end
  end
end
