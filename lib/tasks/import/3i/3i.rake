  require 'fileutils'

  ### rake tw:project_import:access3i:import_all data_directory=/Users/proceps/src/sf/import/3i/TXT/ no_transaction=true

  namespace :tw do
    namespace :project_import do
      namespace :access3i do

      @import_name = '3i'

      # A utility class to index data.
      class ImportedData3i
        attr_accessor :people_index, :user_index, :publications_index, :citations_index, :genera_index, :images_index,
                      :parent_id_index, :statuses, :taxon_index, :citation_to_publication_index, :keywords,
                      :incertae_sedis, :emendation, :original_combination
        def initialize()
          @keywords = {}                  # keyword -> ControlledVocabularyTerm
          @people_index = {}              # PeopleID -> Person object
          @user_index = {}                # PeopleID -> User object
          @publications_index = {}        # Key3 -> Surce object
          @citations_index = {}           # NEW_REF_ID -> row
          @citation_to_publication_index = {} # NEW_REF_ID -> source.id
          @genera_index = {}              # GENUS_NUMBER -> row
          @images_index = {}              # TaxonNo -> row
          @parent_id_index = {}           # Rank:TaxonName -> Taxon.id
          @statuses = {}
          @taxon_index = {}             #Key -> Taxon.id
          @incertae_sedis = {}            #for those taxa which have a parent of incertae sedis
          @emendation = {}                # taxon name emendation source reference key => row
          @original_combination = {}      # original combination key => row
        end
      end

      task :import_all => [:data_directory, :environment] do |t|

        @ranks = {
            0 => '',
            1 => Ranks.lookup(:iczn, :subspecies),
            2 => Ranks.lookup(:iczn, :species),
            4 => 'NomenclaturalRank::Iczn::SpeciesGroup::SpeciesGroup',
            6 => Ranks.lookup(:iczn, :subgenus),
            7 => Ranks.lookup(:iczn, :genus),
            8 => 'NomenclaturalRank::Iczn::GenusGroup::GenusGroup',
            9 => Ranks.lookup(:iczn, :subtribe),
            10 => Ranks.lookup(:iczn, :tribe),
            11 => Ranks.lookup(:iczn, :supertribe),
            12 => Ranks.lookup(:iczn, :subfamily),
            13 => Ranks.lookup(:iczn, :family),
            15 => Ranks.lookup(:iczn, :superfamily),
            17 => Ranks.lookup(:iczn, :infraorder),
            18 => Ranks.lookup(:iczn, :suborder),
            19 => Ranks.lookup(:iczn, :order),
            20 => Ranks.lookup(:iczn, :class),
            21 => Ranks.lookup(:iczn, :subphylum),
            22 => Ranks.lookup(:iczn, :phylum),
            23 => Ranks.lookup(:iczn, :kingdom)
        }

        @relationship_classes = {
            0 => '', ### valid
            1 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym',   #### ::Objective or ::Subjective
            2 => '', ### Original combination
            3 => 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary',
            4 => 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary', #### or 'Secondary::Secondary1961'
            5 => 'TaxonNameRelationship::Iczn::Invalidating::Homonym', ## Preocupied
            6 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression',
            7 => '', ###common name
            8 => 'TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm', #### combination => Combination
            9 => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling',
            10 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation',
            11 => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misapplication',
            12 => '', #### nomen dubium
            13 => '', #### nomen nudum
            14 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName',
            15 => 'TaxonNameRelationship::Iczn::PotentiallyValidating::ReplacementName', #### nomen novum; not used
            16 => '', #### unnamed => OTU
            17 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym', #### new synonym; not used
            18 => '', ### type designation => relationship source.
            19 => '', ### neotype designation => atribute
            20 => '', ### lectotype designation => atribute
            21 => '', ### new status; not used
            22 => 'TaxonNameRelationship::Iczn::Invalidating', ### not binomial
            23 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression',
            24 => 'TaxonNameRelationship::Iczn::Invalidating', ### not available
            25 => 'TaxonNameRelationship::Iczn::PotentiallyValidating::FirstRevisorAction', #### justified emendation
            26 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::SynonymicHomonym',
            27 => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misapplication',
            28 => 'TaxonNameRelationship::Iczn::Invalidating', ### invalid
            29 => 'TaxonNameRelationship::Iczn::Invalidating', ### infrasubspecific

            'type species' => 'TaxonNameRelationship::Typification::Genus',
            'absolute tautonymy' => 'TaxonNameRelationship::Typification::Genus::Tautonomy::Absolute',
            'monotypy' => 'TaxonNameRelationship::Typification::Genus::Monotypy::Original',
            'original designation' => 'TaxonNameRelationship::Typification::Genus::OriginalDesignation',
            'subsequent designation' => 'TaxonNameRelationship::Typification::Genus::Tautonomy',
            'original monotypy' => 'TaxonNameRelationship::Typification::Genus::Monotypy::Original',
            'subsequent monotypy' => 'TaxonNameRelationship::Typification::Genus::Monotypy::Subsequent',
            'Incorrect original spelling' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling',
            'Incorrect subsequent spelling' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling',
            'Junior objective synonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective',
            'Junior subjective synonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
            'Junior subjective Synonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
            'Misidentification' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misapplication',
            'Nomen nudum: Published as synonym and not validated before 1961' => 'TaxonNameRelationship::Iczn::Invalidating',
            'Objective replacement name: Junior subjective synonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
            'Unnecessary replacement name' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName',
            'Suppressed name' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression',
            'Unavailable name: pre-Linnean' => 'TaxonNameRelationship::Iczn::Invalidating',
            'Unjustified emendation' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation',
            'Objective replacement name: Valid Name' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym',
            'Hybrid' => '',
            'Junior homonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym',
            'Manuscript name' => '',
            'Nomen nudum' => '',
            'Nomen nudum: no description' => '',
            'Nomen nudum: No type fixation after 1930' => '',
            'Nomen nudum: Published as synonym and not validated before 1961' => '',
            'Unavailable name: Infrasubspecific name' => '',
            'Unavailable name: pre-Linnean' => '',
            'Suppressed name: ICZN official index of rejected and invalid works' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym',
            'Valid Name' => '',
            'Original_Genus' => 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
            'OrigSubgen' => 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus',
            'Original_Species' => 'TaxonNameRelationship::OriginalCombination::OriginalSpecies',
            'Original_Subspecies' => 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies',
            'Original_Infrasubspecies' => 'TaxonNameRelationship::OriginalCombination::OriginalVariety',
            'Incertae sedis' => 'TaxonNameRelationship::Iczn::Validating::UncertainPlacement'
        }

        @classification_classes = {
            0 => '', ### valid
            12 => 'TaxonNameClassification::Iczn::Available::Valid::NomenDubium',
            13 => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum',
            22 => 'TaxonNameClassification::Iczn::Unavailable::NonBinomial',
            24 => 'TaxonNameClassification::Iczn::Unavailable',
            28 => 'TaxonNameClassification::Iczn::Available::Invalid',
            29 => 'TaxonNameClassification::Iczn::Unavailable::Excluded::Infrasubspecific', ### infrasubspecific
        }

        @languages = {
            'ba' => 'bal',
            'en' => 'eng',
            'fr' => 'fre',
            'ge' => 'ger',
            'ko' => 'kor',
            'ma' => 'hun',
            'sp' => 'spa',
            'ta' => 'tgl',
            'vi' => 'hil'
        }

        if ENV['no_transaction']
          puts 'Importing without a transaction (data will be left in the database).'
          main_build_loop_3i
        else

          ActiveRecord::Base.transaction do
            begin
              main_build_loop_3i
            rescue
              raise
            end
          end

        end

      end

      def main_build_loop_3i
        print "\nStart time: #{Time.now}\n"

        @import = Import.find_or_create_by(name: @import_name)
        @import.metadata ||= {}
        @data =  ImportedData3i.new
        puts @args
        Utilities::Files.lines_per_file(Dir["#{@args[:data_directory]}/**/*.txt"])
        handle_projects_and_users_3i
        raise '$project_id or $user_id not set.'  if $project_id.nil? || $user_id.nil?

        handle_controlled_vocabulary_3i
        #handle_references_3i
        handle_taxonomy_3i

        print "\n\n !! Success. End time: #{Time.now} \n\n"
      end

      def handle_projects_and_users_3i
        print "\nHandling projects and users "
        email = 'arboridia@gmail.com'
        project_name = '3i Auchenorrhyncha'
        user_name = '3i Import'
        $user_id, $project_id = nil, nil
        if @import.metadata['project_and_users']
          print "from database.\n"
          project = Project.where(name: project_name).first
          user = User.where(email: email).first
          $project_id = project.id
          $user_id = user.id
        else
          print "as newly parsed.\n"

          user = User.where(email: email)
          if user.empty?
            user = User.create(email: email, password: '3242341aas', password_confirmation: '3242341aas', name: user_name, self_created: true)
          else
            user = user.first
          end
          $user_id = user.id # set for project line below

          project = nil
          #project = Project.where(name: project_name).first #################### Comment fot creating a new one
          #project = Project.find(35)

          if project.nil?
            project = Project.create(name: project_name)
          end

          $project_id = project.id
          pm = ProjectMember.new(user: user, project: project, is_project_administrator: true)
          pm.save! if pm.valid?

          @import.metadata['project_and_users'] = true
        end
        @root = Protonym.find_or_create_by(name: 'Root', rank_class: 'NomenclaturalRank', project_id: $project_id)

        @data.keywords.merge!('3i_imported' => Keyword.find_or_create_by(name: '3i_imported', definition: 'Imported from 3i database.'))
      end


      def handle_controlled_vocabulary_3i
        print "\nHandling CV \n"

        @data.keywords.merge!(
            #'AuthorDrMetcalf' => Predicate.find_or_create_by(name: 'AuthorDrMetcalf', definition: 'Author name from DrMetcalf bibliography database.', project_id: $project_id),
            '3i_imported' => Keyword.find_or_create_by(name: '3i_imported', definition: 'Imported from 3i database.', project_id: $project_id),
            'CallNumberDrMetcalf' => Predicate.find_or_create_by(name: 'call_number_dr_metcalf', definition: 'Call Number from DrMetcalf bibliography database.', project_id: $project_id),
            #'AuthorReference' => Predicate.find_or_create_by(name: 'author_reference', definition: 'Author string as it appears in the nomenclatural reference.', project_id: $project_id),
            #'YearReference' => Predicate.find_or_create_by(name: 'year_reference', definition: 'Year string as it appears in the nomenclatural reference.', project_id: $project_id),
            'Ethymology' => Predicate.find_or_create_by(name: 'ethymology', definition: 'Ethymology.', project_id: $project_id),
            'TypeDepository' => Predicate.find_or_create_by(name: 'type_depository', definition: 'Type depository.', project_id: $project_id),
            'YearRem' => Predicate.find_or_create_by(name: 'nomenclatural_string', definition: 'Nomenclatural remarks.', project_id: $project_id),
            'Typification' => Predicate.find_or_create_by(name: 'type_designated_by', definition: 'Type designated by', project_id: $project_id),
            'FirstRevisor' => Predicate.find_or_create_by(name: 'first_revisor_action', definition: 'First revisor action', project_id: $project_id),
            'PageAuthor' => Predicate.find_or_create_by(name: 'page_author', definition: 'Page author.', project_id: $project_id),
            'SimilarSpecies' => Predicate.find_or_create_by(name: 'similar_species', definition: 'Similar species.', project_id: $project_id),
            'IDDrMetcalf' => Namespace.find_or_create_by(name: 'DrMetcalf_Source_ID', short_name: 'DrMetcalf_ID'),
            'Key3' => Namespace.find_or_create_by(name: '3i_Source_ID', short_name: '3i_Source_ID'),
            'Key' => Namespace.find_or_create_by(name: '3i_Taxon_ID', short_name: '3i_Taxon_ID'),
            'FLOW-ID' => Namespace.find_or_create_by(name: 'FLOW_Source_ID', short_name: 'FLOW_Source_ID'),
            'DelphacidaeID' => Namespace.find_or_create_by(name: 'Delphacidae_Source_ID', short_name: 'Delphacidae_ID'),
            'Taxonomy' => Keyword.find_or_create_by(name: 'Taxonomy updated', definition: 'Taxonomical information entered to the DB.', project_id: $project_id),
            'Typhlocybinae' => Keyword.find_or_create_by(name: 'Typhlocybinae updated', definition: 'Information related to Typhlocybinae entered to the DB.', project_id: $project_id),
            'Illustrations' => Keyword.find_or_create_by(name: 'Illustrations exported', definition: 'Illustrations of Typhlocybinae species entered to the DB.', project_id: $project_id),
            'Distribution' => Keyword.find_or_create_by(name: 'Distribution exported', definition: 'Illustrations on species distribution entered to the DB.', project_id: $project_id),
            'Notes' => Topic.find_or_create_by(name: 'Notes', definition: 'Notes topic on the OTU.', project_id: $project_id),
        )
      end


      def handle_references_3i

        # Key3
        # AY
        # Author
        # Year
        # Title
        # Bibliography
        # Notes
        # AuthorDrMetcalf
        # VerbatimDrMetcalf ---- Not export
        # CallNumberDrMetcalf
        # NotesDrMetcalf
        # IDDrMetcalf
        # CachedSanborn ---- Not export
        # VerbatimOmanEtAl ---- Not export
        # FLOW-ID
        # DelphacidaeID
        # Key3C ---- Not export
        # Key3D ---- Not export

        path = @args[:data_directory] + 'literature.txt'
        print "\nHandling references\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)
        language = %w(French Russian German Japanese Chinese English Korean Polish Italian Georgian )

        file.each_with_index do |row, i|
          print "\r#{i}"
          journal, serial_id, volume, pages = parse_bibliography_3i(row['Bibliography'])
          year, year_suffix = parse_year_3i(row['Year'])
          taxonomy, distribution, illustration, typhlocybinae = nil, nil, nil, nil
          note = row['Notes']
            source = Source::Bibtex.new( volume: nil,
                                         author: row['AuthorDrMetcalf'].blank? ? row['Author'] : row['AuthorDrMetcalf'],
                                         year: year,
                                         year_suffix: year_suffix,
                                         title: row['Title'],
                                         journal: journal,
                                         serial_id: serial_id,
                                         pages: pages,
                                         volume: volume,
                                         bibtex_type: 'article'
            )

          source.alternate_values.new(value: row['Author'], type: 'AlternateValue::Abbreviation', alternate_value_object_attribute: 'author') if !row['AuthorDrMetcalf'].blank? && row['AuthorDrMetcalf'] != row['Author']

          InternalAttribute.new(attribute_subject: source, predicate: @data.keywords['CallNumberDrMetcalf'], value: row['CallNumberDrMetcalf']) unless row['CallNumberDrMetcalf'].blank?

          source.data_attributes.new(type: 'ImportAttribute', import_predicate: 'Author3i', value: row['AY']) unless row['AY'].blank?
          source.data_attributes.new(type: 'ImportAttribute', import_predicate: 'YearReference', value: row['Year']) unless row['Year'].blank?
          source.data_attributes.new(type: 'ImportAttribute', import_predicate: 'BibliographyReference', value: row['Bibliography']) unless row['Bibliography'].blank?

          if !note.blank? && note.include?('Taxonomy only and distribution')
            a1 = source.tags.new(keyword: @data.keywords['Distribution'])
            note.gsub!(' and distribution', '')
          end
          if !note.blank? && note.include?('Taxonomy only')
            a2 = source.tags.new(keyword: @data.keywords['Taxonomy'])
            note.gsub!('Taxonomy only', '')
          end
          if !note.blank? && note.index('T ') == 0
            a3 = source.tags.new(keyword: @data.keywords['Typhlocybinae'])
            note = note[2..-1]
          end
          if !note.blank? && note.include?('Illustrations done')
            a4 = source.tags.new(keyword: @data.keywords['Illustrations'])
            note.gsub!('Illustrations done', '')
          end
          note.squish! unless note.nil?


          source.notes.new(text: row['NotesDrMetcalf']) unless row['NotesDrMetcalf'].blank?
          source.notes.new(text: note) unless note.blank?

          language.each do |l|
            if (row['Notes'].to_s + ' ' + row['Bibliography'].to_s).include?('In ' + l)
              source.language_id = Language.where(english_name: l).first.id
            end
          end

          source.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['IDDrMetcalf'], identifier: row['IDDrMetcalf']) unless row['IDDrMetcalf'].blank?
          source.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['Key3'], identifier: row['Key3']) unless row['Key3'].blank?
          source.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['FLOW-ID'], identifier: row['FLOW-ID']) if !row['FLOW-ID'].blank? && !row['FLOW-ID'] == '0'
          source.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['DelphacidaeID'], identifier: row['DelphacidaeID']) if !row['DelphacidaeID'].blank? && !row['DelphacidaeID'] == '0'

          source.project_sources.new

          if source.valid?
            source.save!
            @data.publications_index.merge!(row['Key3'] => source.id)
          else
            byebug
          end
        end

        puts "\nResolved #{@data.publications_index.keys.count} publications\n"

      end

      def parse_bibliography_3i(bibl)
        return nil, nil, nil, nil if bibl.blank?

        matchdata = bibl.match(/(^.+)\s+(\d+\(.+\)|\d+): *(\d+-\d+|\d+–\d+|\d+)\.*\s*(.*$)/)
        return bibl, nil, nil, nil if matchdata.nil?

        serial = Serial.where(name: matchdata[1]).first
        serial ||= Serial.with_any_value_for(:name, matchdata[1]).first
        serial_id = serial.nil? ? nil : serial.id
        journal = matchdata[4].blank? ? matchdata[1] : bibl
        volume = matchdata[2]
        pages = matchdata[3]
        return journal, serial_id, volume, pages
      end

      def parse_year_3i(year)
        return nil, nil if year.blank?
        matchdata = year.match(/(\d\d\d\d)(.*)/)
        return nil.nil if matchdata.nil?
        return matchdata[1], matchdata[2]
      end

      def handle_taxonomy_3i

        # Key !
        # Key3 !
        # Name !
        # Author !
        # Year !
        # YearRem !
        # Page !
        # Rank !
        # Status
        # Parent !
        # nameM !
        # nameF !
        # nameN !
        # is_fossil !
        # Gender !
        # Remarks !
        # DescriptEn !
        # PageAuthor !
        # TypeDepository !
        # Ethymology !

        # OrigGen
        # OrigSubGen
        # OriginalSpecies
        # OriginalSubSpecies
        # TypeDesignation
        # Type
        # Homonym
        # MisspellingOf
        # CombinationOf
        # OriginalCombinationOf
        # NomenNovumFor
        # CommonNameLang


        gender = {'M' => 'TaxonNameClassification::Latinized::Gender::Masculine',
                  'F' => 'TaxonNameClassification::Latinized::Gender::Feminine',
                  'N' => 'TaxonNameClassification::Latinized::Gender::Neuter',
                  'm' => 'TaxonNameClassification::Latinized::Gender::Masculine',
                  'f' => 'TaxonNameClassification::Latinized::Gender::Feminine',
                  'n' => 'TaxonNameClassification::Latinized::Gender::Neuter' }

        synonym_statuses = %w(1 6 8 10 11 14 17 22 23 24 26 27 28 29)

      path = @args[:data_directory] + 'taxon.txt'
          print "\nHandling taxonomy\n"
          raise "file #{path} not found" if not File.exists?(path)
          file = CSV.foreach(path, col_sep: "\t", headers: true)


          file.each_with_index do |row, i|
            if i < 200000
            print "\r#{i}"
            if row['Name'] == 'Incertae sedis' || row['Name'] == 'Unplaced'
              @data.incertae_sedis.merge!(row['Key'] => @data.taxon_index[row['Parent']])
            elsif row['Status'] == '7' ### common name
            elsif row['Status'] == '8' && !@data.taxon_index[row['Parent']].rank_class.to_s.include?('Family') ### combination
            elsif row['Status'] == '2'
              @data.original_combination.merge!(row['OriginalCombinationOf'] => row)
            elsif row['Status'] == '16'
              rank = @ranks[row['Rank'].to_i]
              otu = Otu.create!(name: 'Genus ' + row['Name']) if rank.to_s.include?('Genus')
              otu = Otu.create!(name: ('Species ' + @data.taxon_index[row['Parent']].try(:name).to_s + ' ' + row['Name']).squish) if rank.to_s.include?('Species')
              otu.identifiers.create!(type: 'Identifier::Local::Import', namespace: @data.keywords['Key'], identifier: row['Key'])
            elsif row['Status'] == '18'
              taxon = @data.taxon_index[row['Parent']]
              taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['Typification'].id, value: ('Type designation: ' + row['Author'].to_s + ', ' + row['Year'].to_s + row['YearRem'].to_s).squish)
              taxon.valid? ? taxon.save! : byebug
            elsif row['Status'] == '19'
              taxon = @data.taxon_index[row['Parent']]
              taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['Typification'].id, value: ('Neotype designation: ' + row['Author'].to_s + ', ' + row['Year'].to_s + row['YearRem'].to_s).squish)
              taxon.valid? ? taxon.save! : byebug
            elsif row['Status'] == '20'
              taxon = @data.taxon_index[row['Parent']]
              taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['Typification'].id, value: ('Lectotype designation: ' + row['Author'].to_s + ', ' + row['Year'].to_s + row['YearRem'].to_s).squish)
              taxon.valid? ? taxon.save! : byebug
            elsif row['Status'] == '25'  && !@data.taxon_index[row['Parent']].rank_class.to_s.include?('Family') # emendation
              taxon = @data.taxon_index[row['Parent']]
              taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['FirstRevisor'].id, value: (row['Name'] + ' ' + row['Author'].to_s + ', ' + row['Year'].to_s + row['YearRem'].to_s).squish)
              taxon.valid? ? taxon.save! : byebug
              @data.emendation.merge!(row['Parent'] => row)
            else
              name = row['Name'].split(' ').last
              vname = row['Name'].split(' ').last
              #parent = row['Parent'].blank? ? @root : Protonym.with_identifier('3i_Taxon_ID ' + row['Parent']).find_by(project_id: $project_id)
              parent = row['Parent'].blank? ? @root : @data.incertae_sedis[row['Parent']] || @data.taxon_index[row['Parent']]

              if row['Rank'] == '0'
                rank = parent.rank_class
                if rank.parent.to_s == 'NomenclaturalRank::Iczn::FamilyGroup'
                  alternative_name = Protonym.family_group_name_at_rank(name, rank.rank_name)
                  if name != alternative_name
                    name = alternative_name
                    vname = row['Name']
                  end
                end
              else
                rank = @ranks[row['Rank'].to_i]
              end
              if !row['OriginalSpecies'].blank? && row['Rank'] == '2'
                parent = @data.taxon_index[row['OriginalSpecies']]
                rank = @ranks[1]
              end
              byebug if parent.nil?
              byebug if row['Rank'].blank?

              #rank = row['Rank'] == '0' ? parent.rank_class : @ranks[row['Rank'].to_i]
              source = row['Key3'].blank? ? nil : @data.publications_index[row['Key3']] # Source.with_identifier('3i_Source_ID ' + row['Key3']).first
              if row['Rank'] == '0'
                byebug if parent.parent.nil?
                parent = parent.parent
              end

              taxon = Protonym.new( name: name,
                                    parent: parent,
                                    source_id: source,
                                    year_of_publication: row['Year'],
                                    verbatim_author: row['Author'],
                                    rank_class: rank,
                                    masculine_name: row['nameM'],
                                    feminine_name: row['nameF'],
                                    neuter_name: row['nameN'],
                                    verbatim_name: vname,
                                    also_create_otu: true
              )

              taxon.citations.new(source_id: source, pages: row['Page']) unless source.blank?
              taxon.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['Key'], identifier: row['Key'])
              taxon.notes.new(text: row['Remarks']) unless row['Remarks'].blank?
              taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['Ethymology'].id, value: row['Ethymology']) unless row['Ethymology'].blank?
              taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['TypeDepository'].id, value: row['TypeDepository']) unless row['TypeDepository'].blank?
              taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['YearRem'].id, value: row['YearRem']) unless row['YearRem'].blank?
              taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['PageAuthor'].id, value: row['PageAuthor']) unless row['PageAuthor'].blank?

              if !row['DescriptEn'].blank? && row['DescriptEn'].include?('<h2>Similar species</h2>')
                taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['SimilarSpecies'].id, value: row['DescriptEn'].gsub('<h2>Similar species</h2>', '').squish)
              end

              taxon.taxon_name_classifications.new(type: gender[row['Gender']]) unless row['Gender'].blank?
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Fossil') if row['is_fossil'] == '1'
              byebug if row['Status'].blank?
              taxon.taxon_name_classifications.new(type: @classification_classes[row['Status'].to_i]) unless @classification_classes[row['Status'].to_i].blank?

              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Available::OfficialListOfFamilyGroupNamesInZoology') if row['YearRem'].to_s.include?('Official List of Family-Group Names in Zoology')
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Available::OfficialListOfGenericNamesInZoology') if row['YearRem'].to_s.include?('Official List of Generic Names in Zoology')
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Available::OfficialListOfSpecificNamesInZoology') if row['YearRem'].to_s.include?('Official List of Specific Names in Zoology')
              t3 = taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedFamilyGroupNamesInZoology') if row['YearRem'].to_s.include?('Official Index of Rejected and Invalid Family-Group Names in Zoology')
              t1 = taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedGenericNamesInZoology') if row['YearRem'].to_s.include?('Official Index of Rejected and Invalid Generic Names in Zoology')
              t2 = taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedSpecificNamesInZoology') if row['YearRem'].to_s.include?('Official Index of Rejected and Invalid Specific Names in Zoology')
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::LessThanTwoLetters') if name.length == 1

              taxon.iczn_uncertain_placement = @data.incertae_sedis[row['Parent']] if @data.incertae_sedis[row['Parent']]
              taxon.original_variety = taxon if row['Name'].include?(' var. ')
              taxon.original_form = taxon if row['Name'].include?(' f. ')

              if taxon.valid?
                taxon.save!
                @data.taxon_index.merge!(row['Key'] => taxon)
              else
                taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Family/ && row['Status'] != '0' && !taxon.errors.messages[:name].blank?
                taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Species/ && row['Status'] != '0' && taxon.errors.full_messages.include?('Name name must be lower case')
                taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Species/ && row['Status'] != '0' && taxon.errors.full_messages.include?('Name Name must be latinized, no digits or spaces allowed')
                if taxon.valid?
                  taxon.save!
                  @data.taxon_index.merge!(row['Key'] => taxon)
                else
                  print "\n#{row['Key']}         #{row['Name']}"
                  print "\n#{taxon.errors.full_messages}\n"
                  #byebug
                end
                if !row['DescriptEn'].blank? && (row['DescriptEn'].include?('<h2>Notes</h2>') || row['DescriptEn'].include?('<h2>Remarks</h2>'))
                  taxon.otus.first.contents.new(topic_id: @data.keywords['Notes'], text: row['DescriptEn'].gsub('<h2>Notes</h2>').gsub('<h2>Remarks</h2>').squish)
                end

              end

            end

            end ############################
          end


        # OrigGen !
        # OrigSubGen !
        # OriginalSpecies !
        # OriginalSubSpecies !
        # TypeDesignation !
        # Type !
        # Homonym !
        # MisspellingOf
        # CombinationOf !
        # OriginalCombinationOf
        # NomenNovumFor !

        file.each_with_index do |row, i|
          print "\r#{i} (Relationships)"
          taxon = @data.taxon_index[row['Key']]
          if !taxon.nil? ### original combinations, synonyms, types
            taxon.original_genus = @data.taxon_index[row['OrigGen']] unless row['OrigGen'].blank?
            taxon.original_species = @data.taxon_index[row['OrigSpecies']] unless row['OrigSpecies'].blank?
            taxon.original_subspecies = @data.taxon_index[row['OrigSubSpecies']] unless row['OrigSubSpecies'].blank?
            if taxon.rank_string =~ /Genus/
              taxon.original_genus.nil? ? taxon.original_genus = taxon : taxon.original_subgenus = taxon
            elsif taxon.rank_string =~ /Species/
              if taxon.original_species.nil?
                taxon.original_species = taxon
              elsif taxon.original_subspecies.nil? && taxon.original_variety.nil? && taxon.original_form.nil?
                taxon.original_subspecies = taxon
              elsif taxon.original_variety.nil?
                taxon.original_variety = taxon
              end
            end

            if taxon.rank_string =~ /Genus/ && !row['Type'].blank?
              case row['TypeDesignation']
                when 'original monotypy'
                  taxon.type_species_by_original_monotypy = @data.taxon_index[row['Type']]
                when 'monotypy'
                  taxon.type_species_by_monotypy = @data.taxon_index[row['Type']]
                when 'subsequent monotypy'
                  taxon.type_species_by_subsequent_monotypy = @data.taxon_index[row['Type']]
                when 'original designation'
                  taxon.type_species_by_original_designation = @data.taxon_index[row['Type']]
                when 'subsequent designation'
                  taxon.type_species_by_subsequent_designation = @data.taxon_index[row['Type']]
                when 'ruling by commission'
                  taxon.type_species_by_ruling_by_Commission = @data.taxon_index[row['Type']]
                else
                  taxon.type_species = @data.taxon_index[row['Type']]
              end
            end
            taxon.type_genus = @data.taxon_index[row['Type']] if taxon.rank_string =~ /Family/ && !row['Type'].blank?
            taxon.iczn_set_as_primary_homonym_of = @data.taxon_index[row['Homonym']] if !row['Homonym'].blank? && row['Status'] == '3'
            taxon.iczn_set_as_secondary_homonym_of = @data.taxon_index[row['Homonym']] if !row['Homonym'].blank? && row['Status'] == '4'
            taxon.iczn_set_as_homonym_of = @data.taxon_index[row['Homonym']] if !row['Homonym'].blank? && row['Status'] == '5'
            taxon.iczn_set_as_replacement_name_of = @data.taxon_index[row['NomenNovumFor']] if !row['NomenNovumFor'].blank?
            taxon.iczn_set_as_misspelling_of = @data.taxon_index[row['MisspellingOf']] if !row['MisspellingOf'].blank?
            taxon.iczn_set_as_misspelling_of = @data.taxon_index[row['Parent']] if row['MisspellingOf'].blank? && row['Status'] == '9'
            taxon.iczn_set_as_incorrect_original_spelling_of = @data.taxon_index[row['OriginalCombinationOf']] if !row['OriginalCombinationOf'].blank? && row['Status'] == '9'
            #taxon.iczn_first_revisor_action = @data.taxon_index[row['Parent']] if !row['OriginalCombinationOf'].blank? && row['Status'] == '9'

            source = nil
            if !@data.emendation[row['Parent']].blank? && row['OriginalCombinationOf'] == row['Parent']
              source = @data.emendation[row['Parent']].try(['Key3']).nil? ? nil : @data.publications_index[@data.emendation[row['Parent']]['Key3']] unless @data.emendation[row['Parent']].nil?
              tnr = TaxonNameRelationship::Iczn::PotentiallyValidating::FirstRevisorAction.create(object_taxon_name: @data.emendation[row['Parent']]['Parent'], subject_taxon_name: taxon, source_id: source) if !@data.emendation[row['Parent']].blank? && row['OriginalCombinationOf'] == row['Parent']
              byebug unless tnr.valid?
            end

            if taxon.valid?
              taxon.save!
            else
              byebug
            end

            if synonym_statuses.include?(row['Status']) # %w(1 6 8 10 11 14 17 22 23 24 26 27 28 29)
              tnr = TaxonNameRelationship.create(subject_taxon_name: taxon, object_taxon_name: @data.taxon_index[row['Parent']], type: @relationship_classes[row['Status'].to_i])
              byebug unless tnr.valid?
            end

          elsif row['Status'] == '8' || row['Status'] == '25' ### taxon name combinations
            taxon = @data.taxon_index[row['CombinationOf']] || @data.taxon_index[row['Parent']]

            source = row['Key3'].blank? ? nil : @data.publications_index[row['Key3']]
            c = Combination.new(source_id: source, verbatim_author: row['Author'], year_of_publication: row['Year'])

            c.citations.new(source_id: source, pages: row['Page']) unless source.blank?
            c.genus = @data.taxon_index[row['OrigGen']] unless row['OrigGen'].blank?
            c.species = @data.taxon_index[row['OrigSpecies']] unless row['OrigSpecies'].blank?
            c.subspecies = @data.taxon_index[row['OrigSubSpecies']] unless row['OrigSubSpecies'].blank?
            c.variety = taxon if row['Name'].include?(' var. ')
            c.form = taxon if row['Name'].include?(' f. ')
            c.parent = @data.taxon_index[row['OrigGen']].parent
            if taxon.rank_string =~ /Genus/
              c.genus.nil? ? c.genus = taxon : c.subgenus = taxon
            elsif taxon.rank_string =~ /Species/
              if c.species.nil?
                c.species = taxon
              elsif c.subspecies.nil? && c.variety.nil? && c.form.nil?
                c.subspecies = taxon
              elsif c.variety.nil?
                c.variety = taxon
              end
            elsif taxon.rank_string =~ /Family/

            end
            c.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['YearRem'].id, value: row['YearRem']) unless row['YearRem'].blank?

            i3_combination = '<i>' + @data.taxon_index[row['OrigGen']].try(:name).to_s + '</i> '
            i3_combination += '(<i>' + @data.taxon_index[row['OrigSubGen']].try(:name).to_s + '</i>) ' unless row['OrigSubGen'].blank?
            i3_combination += '<i>' + row['Name'] + '</i>'
            i3_combination = i3_combination.gsub(' f. ', '</i> f. <i>').
                                                 gsub(' var. ', '</i> var. <i>').
                                                 gsub('<i></i>', '').
                                                 gsub('</i> <i>', ' ')
            i3_combination.squish!


            if c.valid?
              c.save!
              if !i3_combination.blank? && i3_combination != c.cached_html
                c.data_attributes.create(type: 'ImportAttribute', import_predicate: 'combination_in_3i', value: i3_combination)
                c.data_attributes.create(type: 'ImportAttribute', import_predicate: 'name_in_3i', value: row['Name'])
              end
            else
              byebug
            end

          elsif row['Status'] == '7' #  common name
            lng = Language.find_by_alpha_3_bibliographic(@languages[row['CommonNameLang'].to_s.downcase])
            CommonName.create!(otu: @data.taxon_index[row['Parent']].otus.first, name: row['Name'], language: lng)
          elsif row['Status'] == '2' || !row['OriginalCombinationOf'].blank? ### Original combination
            taxon = @data.taxon_index[row['OriginalCombinationOf']] || @data.taxon_index[row['Parent']]
            taxon.verbatim_name = row['Name'].split(' ').last
            taxon.original_species = nil
            taxon.original_subspecies = nil
            taxon.original_variety = nil
            taxon.original_form = nil
            taxon.original_species = @data.taxon_index[row['OrigSpecies']] unless row['OrigSpecies'].blank?
            taxon.original_subspecies = @data.taxon_index[row['OrigSubSpecies']] unless row['OrigSubSpecies'].blank?
            taxon.original_variety = taxon if row['Name'].include?(' var. ')
            taxon.original_form = taxon if row['Name'].include?(' f. ')
            if taxon.rank_string =~ /Species/
              if taxon.original_species.nil?
                taxon.original_species = taxon
              elsif taxon.original_subspecies.nil? && taxon.original_variety.nil? && taxon.original_form.nil?
                taxon.original_subspecies = taxon
              elsif taxon.original_variety.nil?
                taxon.original_variety = taxon
              end
            end
            if taxon.valid?
              taxon.save!
            else
              byebug
            end



          end

        end



        end

      end
    end
  end
