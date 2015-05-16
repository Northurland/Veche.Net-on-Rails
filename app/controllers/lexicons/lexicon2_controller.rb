module Lexicons
  class Lexicon2Controller < ApplicationController
    layout 'lexicon2'
    before_filter :set_language
    before_filter :preprocess_search_params
    before_filter :set_display_options

    # See Lexicon model for detailed descriptions
    SEARCH_STRING_PARAMS = [
      :word,
      :transliteration,
      :definition,
      :part_of_speech,
      :root,
      :root_word,
      :root_transliteration,
      :derivatives,
      :any
    ]
    SEARCH_BOOLEAN_PARAMS = [:exact, :whole_word]
    SEARCH_REFERENTIAL_PARAMS = [:related_to]
    SEARCH_PARAM_WHITELIST = [SEARCH_STRING_PARAMS, SEARCH_BOOLEAN_PARAMS, SEARCH_REFERENTIAL_PARAMS, :search].flatten

    def init
      @data = {
        language: @lexicon,
        lexemeField: @lexicon.lexicon_class.indexed_column,
        endpoint: lexicon2_entries_path
      }
    end

    def index
      @lexicon.scope_entries(search_params)
      render :json => @lexicon.entries
    end

    def show
      @entry = @lexicon.entry(params[:slug])
      if @entry.respond_to?(:morphology) && @entry.morphology
        partial = "lexicons/lexicon/morphology/" +
                  @language.downcase.to_s +
                  "_" +
                  @entry.morphology.category.to_s.pluralize
        @entry.morphology_table = render_to_string :partial => partial, :locals => {:m => @entry.morphology.generate!}
      end
      render :json => @entry
    end

    private

    def set_language
      @language = params[:language].to_sym
      @lexicon = Lexicon.find_by_language(@language)
    end

    def set_display_options
      @show_partial_matches = search_params.include? :search
    end

    def preprocess_search_params
      SEARCH_STRING_PARAMS.each do |param|
        if search_params[param].present?
          case params["#{param}_opts"]
            when "contains" then @search_params[param] = "*#{@search_params[param]}*"
            when "begins_with" then @search_params[param] = "#{@search_params[param]}*"
            when "ends_with" then @search_params[param] = "*#{@search_params[param]}"
          end

          # If any advanced options are given, ensure the basic search is disabled
          @search_params.delete :search
        end
      end
    end

    def search_params
      @search_params ||= params.symbolize_keys.keep_if do |k, v|
        SEARCH_PARAM_WHITELIST.include?(k) && v.present?
      end
    end
  end
end