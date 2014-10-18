# encoding: utf-8


##
# note/todo:
##  breweries - same name possible for record!! - add city to make "unique"

task :by do |t|    # check breweries file

  # map file name
  us_root = './o/us-united-states'
  be_root = './o/be-belgium'
  de_root = './o/de-deutschland'

  ## us_root = '../us-united-states'
  ## be_root = '../be-belgium'
  ## de_root = '../de-deutschland'


  in_path = './o/breweries.csv'     ## 1414 rows

  ## try a dry test run
  i = 0
  CSV.foreach( in_path, headers: true ) do |row|
    i += 1
    print '.' if i % 100 == 0
  end
  puts " #{i} rows"


  country_list = CountryList.new
  i = 0
  CSV.foreach( in_path, headers: true ) do |row|
    i += 1
    print '.' if i % 100 == 0

    country = row['country']
    state   = row['state']
    if country.nil?
      puts " *** warn - row #{i} - country is nil; skipping: #{row.inspect}\n\n"
      next  ## skip line; issue warning
    end

    if state.nil? && country == 'United States'
      puts " *** warn - row #{i} - united states - state is nil; #{row.inspect}\n\n"
    end

    if state.nil? && country == 'Belgium'
      puts " *** warn - row #{i} - belgium - state is nil; #{row.inspect}\n\n"
    end

    by = Brewery.new.from_row( row )
    if by.closed?
      puts "*** row #{i} - skip closed brewery >#{by.name}<"
      next ## skip closed breweries; issue warning
    end

    country_list.update_brewery( by )
  end



  ### pp usage.to_a

  puts "\n\n"
  puts "## Country stats:"

  ary = country_list.to_a

  puts "  #{ary.size} countries"
  puts ""

  ary.each_with_index do |c,j|
    print '%5s ' % "[#{j+1}]"
    print '%-30s ' % c.name
    print ' :: %4d breweries' % c.count
    print "\n"
    
    if c.name == 'United States'  ||
       c.name == 'Belgium'        ||
       c.name == 'Germany'
      # do nothing; save states/provinces
    else
      country_key = COUNTRIES_MAPPING[ c.name ]
      country_dir = COUNTRIES[ country_key ]
      if country_dir
        ## path = "./o/#{country_dir}/breweries.csv"
        path = "../#{country_dir}/breweries.csv"
        save_breweries( path, c.breweries )
      else
        puts "*** warn: no country mapping defined for >#{country_key}< >#{c.name}<"
      end
    end

    ## check for states:
    states_ary = c.states.to_a
    if states_ary.size > 0
      puts "   #{states_ary.size} states:"
      states_ary.each_with_index do |state,k|
          print '   %5s ' % "[#{k+1}]"
          print '%-30s ' % state.name
          print '   :: %4d breweries' % state.count
          print "\n"

          if c.name == 'United States'
            us_state_dir = US_STATES[ state.name.downcase ]

            if us_state_dir
              path = "#{us_root}/#{us_state_dir}/breweries.csv"
              save_breweries( path, state.breweries )
            else
              puts "*** warn: no state mapping defined for >#{state.name}<"
            end
          elsif c.name == 'Belgium'
            be_state_dir = BE_STATES[ state.name.downcase ]

            if be_state_dir
              path = "#{be_root}/#{be_state_dir}/breweries.csv"
              save_breweries( path, state.breweries )
            else
              puts "*** warn: no state mapping defined for >#{state.name}<"
            end
          elsif c.name == 'Germany'
            de_state_dir = DE_STATES[ state.name.downcase ]

            if de_state_dir
              path = "#{de_root}/#{de_state_dir}/breweries.csv"
              save_breweries( path, state.breweries )
            else
              puts "*** warn: no state mapping defined for >#{state.name}<"
            end
          else
            # undefined country; do nothing
          end

          ## state.dump  # dump breweries
      end
    end


  end

  puts 'done'
end

