require_relative 'formatter'

module Lexicons
  class Novegradian < ActiveRecord::Base
    include LexiconEntry

    self.table_name = 'novegradian'

    has_many :cross_reference_links, :foreign_key => :from, :class_name => NovegradianCrossReference
    has_many :cross_references, :through => :cross_reference_links, :source => :novegradian
    has_one :morphology, :foreign_key => :entry_id, :class_name => NovegradianMorphology

    field :word, :formatter => CanonicalFormFormatter
    field :transliteration, :formatter => TransliterationFormatter
    field :pronunciation, :formatter => PronunciationFormatter
    field :part_of_speech, :formatter => PartOfSpeechFormatter
    field :root, :formatter => RootFormatter
    field :definition, :formatter => DefinitionFormatter
    field :important_forms, :formatter => ImportantFormsFormatter
    field :idioms, :formatter => IdiomFormatter
    field :notes, :formatter => NoteFormatter
    field :etymology, :formatter => EtymologyFormatter
    field :cognates, :formatter => CognateFormatter

    field :cross_references, :formatter => CrossReferenceFormatter, :custom => true
    field :morphology_table, :formatter => MorphologyFormatter, :custom => true

    attr_accessor :morphology_table

    before_create :generate_slug

    # Array of fields that are included when doing a search over "any" field.
    def self.scopable_fields
      [
        :word,
        :transliteration,
        :definition,
        :idioms,
        :notes
      ]
    end

    # Array of fields that are included when doing a generic (non-advanced) search.
    def self.primary_fields
      [
        :word,
        :transliteration,
        :definition
      ]
    end

    # The name of the column that lexicon entries are listed under
    def self.indexed_column
      :word
    end

    # Convert a search parameter into one or more corresponding columns
    # in this table to search through
    def self.map_search_params(field)
      {
        :word => :word,
        :part_of_speech => :part_of_speech,
        :transliteration => :transliteration,
        :root => :root,
        :definition => :definition
      }[field]
    end

    def cross_references
      super.order(:word)
    end

    def morphology_hash
      if morphology
        morphology.as_json
      else
        NovegradianMorphology.new.as_json
      end
    end

    def to_json(opts={})
      formatters.reduce({}) do |hash, formatter|
        hash[formatter.name] = formatter.to_html
        hash
      end.to_json
    end

    def self.create_entry(params)
      record = new(
        word: params[:word],
        transliteration: params[:transliteration],
        pronunciation: params[:pronunciation],
        part_of_speech: params[:part_of_speech],
        root: params[:root],
        definition: params[:definition],
        important_forms: params[:important_forms],
        idioms: params[:idioms],
        notes: params[:notes],
        etymology: params[:etymology],
        cognates: params[:cognates]
      )
      if params[:morphology_table]
        record.morphology = NovegradianMorphology.new(params[:morphology_table])
      end
      if params[:cross_references]
        params[:cross_references].split(',').each do |xref|
          record.cross_references << where(:slug => xref).first
        end
      end

      record.save!
      record
    end

    def update_entry(params)
      update_attributes(
        word: params[:word],
        transliteration: params[:transliteration],
        pronunciation: params[:pronunciation],
        part_of_speech: params[:part_of_speech],
        root: params[:root],
        definition: params[:definition],
        important_forms: params[:important_forms],
        idioms: params[:idioms],
        notes: params[:notes],
        etymology: params[:etymology],
        cognates: params[:cognates]
      )
      if morphology
        morphology.update_attributes(params[:morphology_table])
      elsif params[:morphology_table]
        self.morphology = NovegradianMorphology.new(params[:morphology_table])
      end
      xrefs = (params[:cross_references] || "").split(',')
      cross_references.each do |xref|
        if !xrefs.include?(xref.slug)
          cross_references.delete(xref)
        end
      end
      xrefs.each do |xref|
        if !cross_references.map(&:slug).include?(xref)
          cross_references << where(:slug => xref).first
        end
      end
      save!
    end
  end
end
