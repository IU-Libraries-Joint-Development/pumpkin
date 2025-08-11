module IuDevOps
  class ReindexSolrToSolr

    # Only url is needed for new solr but other config options can be passed in addition
    attr_accessor :old_solr, :new_solr

    def initialize(new_solr_config:, old_solr_config:)
      @old_solr = ActiveFedora::SolrService.new(old_solr_config) if old_solr_config.present?
      @old_solr ||= ActiveFedora.solr
      @new_solr = ActiveFedora::SolrService.new(new_solr_config)
    end

    # Example reindexing a delta via query: "timestamp:[#{(DateTime.now - 1.day).utc.iso8601} TO *]"
    def reindex(query: "*", batch_size: 1000)
      puts "Old solr: #{@old_solr.conn.uri.to_s}"
      puts "New solr: #{@new_solr.conn.uri.to_s}"

      total_docs = old_solr.conn.get('select', params: {q: query, rows: 0})["response"]["numFound"]
      if total_docs == 0
        puts "No documents found to reindex."
        return
      end

      puts "Starting reindex of #{total_docs} docs at #{DateTime.now.utc.iso8601}"
      docs_processed = total_docs_processed = 0
      while docs_processed < total_docs
        docs = old_solr.conn.get('select', params: {q: query, fl: '*', sort: 'timestamp asc', rows: batch_size, start: docs_processed})["response"]["docs"]

        reconstructed_docs = docs.collect do |doc|
          begin
            SolrDocReconstructor.new(doc).reconstruct
          rescue RuntimeError => e
            puts "Error reconstructing #{doc["id"]}...falling back to ActiveFedora method"
            puts e.message
            begin
               ActiveFedora::Base.find(doc["id"]).to_solr
            rescue Ldp::Gone
              puts "Object no longer exists in Fedora (Ldp::Gone)"
            rescue RuntimeError => e2
              puts "Error reindexing from Fedora"
              puts e.message
            end
          end
        end

        reconstructed_docs.compact!
        new_solr.conn.add(reconstructed_docs, {softCommit: true})
        docs_processed += docs.size
        total_docs_processed += reconstructed_docs.size
        puts "Migrated #{total_docs_processed} out of #{total_docs}"
      end
      puts "Committing..."
      new_solr.conn.commit
      puts "Optimizing..."
      new_solr.conn.optimize
      puts "Complete at #{DateTime.now.utc.iso8601}"
    end

    class SolrDocReconstructor
      STORED_DEFINITIONS = ["stored_searchable", "stored_sortable", "displayable", "symbol"]
      NON_STORED_DEFINITIONS = ["facetable", "searchable", "sortable"]

      attr_accessor :doc, :fs_with_text_content
      
      def initialize(doc, fs_with_text_content: false)
        @doc = doc
        @fs_with_text_content = fs_with_text_content
      end

      def reconstruct
        klass = detect_class(doc)
        new_doc = doc.except("timestamp", "score", "_version_")
        reconstruct_class(new_doc, klass, fs_with_text_content)
        reconstruct_includes(new_doc, klass)
        new_doc
      end

      private

      def detect_class(doc)
        doc["has_model_ssim"]&.first&.safe_constantize || Object
      end

      def find_value(field, stored_def, new_doc)
        case stored_def
        when "stored_searchable"
          new_doc["#{field}_tesim"] || new_doc["#{field}_dtsim"] || new_doc["#{field}_isim"]
        when "displayable"
          new_doc["#{field}_ssm"]
        when "symbol"
          new_doc["#{field}_ssim"]
        when "stored_sortable"
          new_doc["#{field}_ssi"] || new_doc["#{field}_dtsi"]
        default
          nil
        end
      end

      def find_value_type(value)
        case value
        when String
          :string
        when Integer
          :integer
        when DateTime
          :time
        when TrueClass, FalseClass
          :boolean
        when Array
          find_value_type(value.first)
        end
      end

      def set_value(field, non_store_def, value, new_doc)
          value_type = find_value_type(value)
          case non_store_def
          when "facetable"
            new_doc["#{field}_sim"] = value
          when "searchable"
            if value_type == :string
              new_doc["#{field}_teim"] = value
            elsif value_type == :time
              new_doc["#{field}_dtim"] = value
            elsif value_type == :integer
              new_doc["#{field}_iim"] = value
            end
          when "unstemmed_searchable"
            new_doc["#{field}_tim"] = value
          end
      end

      # Characterization terms (e.g. width, height) are all stored and defined in CurationConcerns::FileSetIndexer

      # CurationConcerns::RequiredMetadata
      REQUIRED_METADATA_FIELDS = {
        "title_sim" => "title_tesim"
      }

      # CurationConcerns::HumanReadableType
      HUMAN_READABLE_FIELDS = {
        "human_readable_type_sim" => "human_readable_type_tesim"
      }

      # CurationConcerns::BasicMetadata
      BASIC_METADATA_FIELDS = {
        "resource_type_sim" => "resource_type_tesim",
        "creator_sim" => "creator_tesim",
        "contributor_sim" => "contributor_tesim",
        "keyword_sim" => "keyword_tesim",
        "publisher_sim" => "publisher_tesim",
        "subject_sim" => "subject_tesim",
        "language_sim" => "language_tesim",
        "based_near_sim" => "based_near_tesim"
      }

      PLUM_SCHEMA_FIELDS = ["sort_title", "portion_note", "description", "identifier", "replaces", "rights_statement", "rights_note", "source_metadata_identifier", "state", "workflow_note", "holding_location", "ocr_language", "nav_date", "pdf_type", "full_text_searchable", "start_canvas", "alternative_title", "digital_date", "usage_right", "volume_and_issue_no", "edition", "series", "coverage", "date", "digital_specifications", "digital_collection", "digital_publisher", "extent", "date_published", "modified", "lccn_call_number", "local_call_number", "physical_description", "abridger", "actor", "adapter", "addressee", "analyst", "animator", "annotator", "appellant", "appellee", "applicant", "architect", "arranger", "art_copyist", "art_director", "artist", "artistic_director", "assignee", "associated_name", "attributed_name", "auctioneer", "author", "author_in_quotations_or_text_abstracts", "author_of_afterword_colophon_etc", "author_of_dialog", "author_of_introduction_etc", "autographer", "bibliographic_antecedent", "binder", "binding_designer", "blurb_writer", "book_designer", "book_producer", "bookjacket_designer", "bookplate_designer", "bookseller", "braille_embosser", "broadcaster", "calligrapher", "cartographer", "caster", "censor", "choreographer", "cinematographer", "client", "collection_registrar", "collector", "collotyper", "colorist", "commentator", "commentator_for_written_text", "compiler", "complainant", "complainant_appellant", "complainant_appellee", "composer", "compositor", "conceptor", "conductor", "conservator", "consultant", "consultant_to_a_project", "contestant", "contestant_appellant", "contestant_appellee", "contestee", "contestee_appellant", "contestee_appellee", "contractor", "copyright_claimant", "copyright_holder", "corrector", "correspondent", "costume_designer", "court_governed", "court_reporter", "cover_designer", "curator", "dancer", "data_contributor", "data_manager", "dedicatee", "dedicator", "defendant", "defendant_appellant", "defendant_appellee", "degree_granting_institution", "degree_supervisor", "delineator", "depicted", "designer", "director", "dissertant", "distribution_place", "distributor", "owning_institution", "draftsman", "dubious_author", "editor", "editor_of_compilation", "editor_of_moving_image_work", "electrician", "electrotyper", "enacting_jurisdiction", "engineer", "engraver", "etcher", "event_place", "expert", "facsimilist", "field_director", "film_distributor", "film_director", "film_editor", "film_producer", "filmmaker", "first_party", "forger", "former_owner", "funding", "geographic_information_specialist", "honoree", "host", "host_institution", "illuminator", "illustrator", "inscriber", "instrumentalist", "interviewee", "interviewer", "author", "issuing_body", "judge", "jurisdiction_governed", "laboratory", "laboratory_director", "landscape_architect", "lead", "lender", "libelant", "libelant_appellant", "libelant_appellee", "libelee", "libelee_appellant", "libelee_appellee", "librettist", "licensee", "licensor", "lighting_designer", "lithographer", "lyricist", "manufacture_place", "manufacturer", "marbler", "markup_editor", "medium", "metadata_contact", "metal_engraver", "minute_taker", "moderator", "monitor", "music_copyist", "musical_director", "musician", "narrator", "onscreen_presenter", "opponent", "organizer", "originator", "other", "owner", "panelist", "papermaker", "patent_applicant", "patent_holder", "patron", "performer", "permitting_agency", "photographer", "plaintiff", "plaintiff_appellant", "plaintiff_appellee", "platemaker", "praeses", "presenter", "printer", "printer_of_plates", "printmaker", "process_contact", "producer", "production_company", "production_designer", "production_manager", "production_personnel", "production_place", "programmer", "project_director", "proofreader", "provider", "publication_place", "publishing_director", "puppeteer", "radio_director", "radio_producer", "recording_engineer", "recordist", "redaktor", "renderer", "reporter", "marc_repository", "research_team_head", "research_team_member", "researcher", "respondent", "respondent_appellant", "respondent_appellee", "responsible_party", "restager", "restorationist", "reviewer", "rubricator", "scenarist", "scientific_advisor", "screenwriter", "scribe", "sculptor", "second_party", "secretary", "seller", "set_designer", "setting", "signer", "singer", "sound_designer", "speaker", "sponsor", "stage_director", "stage_manager", "standards_body", "stereotyper", "storyteller", "supporting_host", "surveyor", "teacher", "technical_director", "television_director", "television_producer", "thesis_advisor", "transcriber", "translator", "type_designer", "typographer", "university_place", "videographer", "voice_actor", "witness", "wood_engraver", "woodcutter", "writer_of_accompanying_material", "writer_of_added_commentary", "writer_of_added_text", "writer_of_added_lyrics", "writer_of_supplementary_textual_content", "writer_of_introduction", "writer_of_preface", "call_number", "published", "responsibility_note"]

      def reconstruct_includes(new_doc, klass)
        REQUIRED_METADATA_FIELDS.each { |unstored, stored| new_doc[unstored] = new_doc[stored] } if klass.ancestors.include? CurationConcerns::RequiredMetadata
        BASIC_METADATA_FIELDS.each { |unstored, stored| new_doc[unstored] = new_doc[stored] } if klass.ancestors.include? CurationConcerns::BasicMetadata
        HUMAN_READABLE_FIELDS.each { |unstored, stored| new_doc[unstored] = new_doc[stored] } if klass.ancestors.include? CurationConcerns::HumanReadableType
        new_doc
      end

      def reconstruct_class(new_doc, klass, has_text_content=false)
        class_metadata_fields = case klass.to_s
                                when Collection.to_s
                                  {}
                                when FileSet.to_s
                                  {
                                    # Hyrax::FileSetIndexer
                                    "file_format_sim" => "file_format_tesim",
                                    "all_text_timv" => "all_text_tsimv" 
                                  }
                                when MultiVolumeWork.to_s, ScannedResource.to_s
                                  PLUM_SCHEMA_FIELDS.collect { |k| ["#{k}_sim","#{k}_tesim"] }.to_h
                                else
                                  {}
                                end

        class_metadata_fields.each { |unstored, stored| new_doc[unstored] = new_doc[stored] }

        if klass == FileSet && has_text_content
          # tsimv doesn't exist so actually need to look up the value from fedora (this is faster than calling update_index
          new_doc["all_text_timv"] = FileSet.find(new_doc["id"]).extracted_text&.content
        end

        # generic_type_sim
        generic_type = case klass.to_s
                       when Collection.to_s
                         "Collection"
                       when MultiVolumeWork.to_s, ScannedResource.to_s
                         "Work"
                       else
                         nil
                       end
        new_doc["generic_type_sim"] = [generic_type]

        # Some documents have source_metadata_ssm but they can't be indexed in solr9 because they are too large so move them over to a text field
        if new_doc["source_metadata_ssm"].present?
          new_doc["source_metadata_tesim"] = new_doc["source_metadata_ssm"]
          new_doc["source_metadata_ssm"] = nil
        end

        new_doc
      end
    end

    class ReconstructedDocValidator
      def self.validate_reconstructed_solr_doc(reconstructed_doc)
        original_doc = ActiveFedora::Base.find(reconstructed_doc["id"]).to_solr.stringify_keys!.select {|k,v| v.present?}
        original_doc.map do |k,v|
          if k.end_with? "m"
            original_doc[k] = Array(v)
          elsif k =~ /_s[a-z]*$/
            original_doc[k] = v.to_s
          end
        end

        hash_diff = HashDiff::Comparison.new(original_doc, reconstructed_doc)
        missing_or_changed_fields = hash_diff.diff.select {|k,v| !(v[0].nil? || v[0] == HashDiff::NO_VALUE) }
        #missing_or_changed_fields.empty? ? true : false
      end
    end
  end
end

# Taken from HashDiff gem and modified to sort arrays given rdf is non-deterministic as to order of values
module HashDiff
  class NO_VALUE; end

  class Comparison
    def initialize(left, right)
      @left  = left
      @right = right
    end

    attr_reader :left, :right

    def diff
      @diff ||= find_differences { |l, r| [l, r] }
    end

    def left_diff
      @left_diff ||= find_differences { |_, r| r }
    end

    def right_diff
      @right_diff ||= find_differences { |l, _| l }
    end

    protected

    def find_differences(&reporter)
      combined_keys.each_with_object({ }, &comparison_strategy(reporter))
    end

    private

    def comparison_strategy(reporter)
      lambda do |key, diff|
        diff[key] = report_difference(key, reporter) unless equal?(key)
      end
    end

    def combined_keys
      if hash?(left) && hash?(right) then
        (left.keys + right.keys).uniq
      elsif array?(left) && array?(right) then
        (0..[left.size, right.size].max).to_a
      else
        raise ArgumentError, "Don't know how to extract keys. Neither arrays nor hashes given"
      end
    end

    def equal?(key)
      value_with_default(left, key) == value_with_default(right, key)
    end

    def hash?(value)
      value.is_a?(Hash)
    end

    def array?(value)
      value.is_a?(Array)
    end

    def comparable_hash?(key)
      hash?(left[key]) && hash?(right[key])
    end

    def comparable_array?(key)
      array?(left[key]) && array?(right[key])
    end

    def report_difference(key, reporter)
      if comparable_hash?(key)
        self.class.new(left[key], right[key]).find_differences(&reporter)
      elsif comparable_array?(key)
        self.class.new(left[key], right[key]).find_differences(&reporter)
      else
        reporter.call(
          value_with_default(left, key),
          value_with_default(right, key)
        )
      end
    end

    def value_with_default(obj, key)
      value = obj.fetch(key, NO_VALUE)
      value.sort if array?(value)
    end
  end
end
