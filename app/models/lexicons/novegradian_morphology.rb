Dir["#{File.dirname(__FILE__)}/novegradian_morphology/**/*.rb"].each {|f| require f}

module Lexicons
  class NovegradianMorphology < ActiveRecord::Base
    self.table_name = 'novegradian_morphology'

    belongs_to :novegradian, :foreign_key => :entry_id
    has_many :extensions, :foreign_key => :base_id, :class_name => NovegradianMorphology
    belongs_to :novegradian_morphology, :foreign_key => :base_id

    ATTRIBUTES = [
      :entry_id, :base_id, :category, :stem, :stem_transliterated, :desinence, :desinence_transliterated,
      :tertiary, :tertiary_transliterated, :group, :subgroup, :flags
    ]

    def self.structure
      lexicon = Lexicon.find_by_slug(:novegradian)
      [
        { :key => "category",
          :options => MorphologyDefinition.categories_for_lexicon(lexicon) },
        { :key => "group",
          :options => MorphologyDefinition.groups_for_lexicon(lexicon) },
        { :key => "subgroup",
          :options => MorphologyDefinition.subgroups_for_lexicon(lexicon) },
        { :key => "stem" },
        { :key => "stem_transliterated" },
        { :key => "desinence" },
        { :key => "desinence_transliterated" },
        { :key => "tertiary" },
        { :key => "tertiary_transliterated" },
        { :key => "flags",
          :options => MorphologyDefinition.flags_for_lexicon(lexicon) }
      ]
    end

    def as_json(options={})
      {
        :category => category,
        :group => group,
        :subgroup => subgroup,
        :stem => stem,
        :stem_transliterated => stem_transliterated,
        :desinence => desinence,
        :desinence_transliterated => desinence_transliterated,
        :tertiary => tertiary,
        :tertiary_transliterated => tertiary_transliterated,
        :flags => flags
      }
    end

    def generate!
      # Import category-specific methods
      module_name = [
        "Morphology",
        "Novegradian",
        category.classify.pluralize
      ].join("::")
      extend module_name.constantize
      # Import specific morphology methods
      module_name = [
        module_name,
        group.titleize.gsub(/[^A-Za-z0-9]/, ''),
        subgroup.titleize.gsub(/[^A-Za-z0-9]/, '')
      ].join("::")
      extend module_name.constantize
      self
    end

    def topicalize(string, case_name, number)
      method = "_#{case_name}_#{number}_topicalized".to_sym
      if respond_to? method
        res = send method
        return MultilingualString.new(res[0], :transliteration => res[1])
      else
        if case_name == :nominative || (case_name == :accusative && !animate?)
          if number == :singular
            case string.to_s[-1]
              when *%w(а я)
                suffix_nov = "-та"
                suffix_tra = "-ta"
              when *%w(е)
                suffix_nov = "-те"
                suffix_tra = "-te"
              when *%w(о ё и ы у ю ѣ ѐ)
                suffix_nov = "-то"
                suffix_tra = "-to"
              else
                suffix_nov = "-от"
                suffix_tra = "-ot"
            end
          else
            case string.to_s[-1]
              when *%w(а я)
                suffix_nov = "-та"
                suffix_tra = "-ta"
              else
                suffix_nov = "-ти"
                suffix_tra = "-ti"
            end
          end
        else
          case string.to_s[-1]
            when *%w(ѣ е и)
              suffix_nov = "-те"
              suffix_tra = "-te"
            else
              suffix_nov = "-то"
              suffix_tra = "-to"
          end
        end
        return MultilingualString.new(string.to_s + suffix_nov, :transliteration => string.transliteration + suffix_tra)
      end
    end

    def vocative
      if has_vocative?
        extensions.where(:group => 'vocative').first
      end
    end

    private

    def method_missing(method, *args, &block)
      if method.to_s[-1] == '?'
        @flags ||= (flags || "").split(' ').map(&:strip).map(&:to_sym)
        @flags.include? method[0..-2].to_sym
      else
        method = "_#{method}".to_sym
        if respond_to? method
          if res = send(method)
            processed = postprocess res, method
            MultilingualString.new(processed[0], :transliteration => processed[1])
          end
        end
      end
    end

    # Override in modules if generic postprocessing treatment is needed
    def postprocess(string, form)
      string
    end

    def remove_stress(string)
      string.gsub(/([áéíóúý]|ě́)/, {
        'á' => 'a',
        'é' => 'e',
        'í' => 'i',
        'ó' => 'o',
        'ú' => 'u',
        'ý' => 'y',
        'ě́' => 'ě'
      })
    end

    def stress_last_vowel(string)
      str = remove_stress(string)
      idx = str.rindex(/[aeiouyě]/)
      str[0...idx] + case str[idx]
        when 'a' then 'á'
        when 'e' then 'é'
        when 'i' then 'í'
        when 'o' then 'ó'
        when 'u' then 'ú'
        when 'y' then 'ý'
        when 'ě' then 'ě́'
      end + str[(idx+1)..-1]
    end
  end
end
