#!/usr/bin/env ruby
# coding: utf-8

require 'dbf'
require 'active_record'
require 'iconv'
require 'progressbar'

module Kladr_sqlite
  class Kladr < ActiveRecord::Base
  end

  class Kladr_street < ActiveRecord::Base
  end

  class City < ActiveRecord::Base
    has_many :streets
  end

  class Street < ActiveRecord::Base
    belongs_to :city
  end


  def Kladr_sqlite.is_city( code )
    return ( ( code[ 5 ] != "0" ) || ( code[ 6 ] != "0" ) || ( code[ 7 ] != "0" ) )
  end

  def Kladr_sqlite.get_city_code( code )
    return code[ 0..10 ] + "00"
  end

  def Kladr_sqlite.create_linked_tables
    ActiveRecord::Schema.define do
     create_table "kladrs" do |t|
        t.column "name", :string, :limit => 40
        t.column "socr", :string, :limit => 10
        t.column "code", :string, :limit => 13
      end
    end
    
    ActiveRecord::Schema.define do
      create_table "cities" do |t|
        t.column "name", :string, :limit => 40
        t.column "socr", :string, :limit => 10
      end
    end
    
    ActiveRecord::Schema.define do
      create_table "streets" do |t|
        t.column "name", :string, :limit => 40
        t.column "socr", :string, :limit => 10
        t.column "city_id", :integer
      end
    end
  end

  def Kladr_sqlite.create_raw_tables
    ActiveRecord::Schema.define do
      create_table "kladrs" do |t|
        t.column "name", :string, :limit => 40
        t.column "socr", :string, :limit => 10
        t.column "code", :string, :limit => 13
        t.column "index", :string, :limit => 6
        t.column "gninmb", :string, :limit => 4
        t.column "uno", :string, :limit => 4
        t.column "ocatd", :string, :limit => 11
        t.column "status", :string, :limit => 1
      end
    end

    ActiveRecord::Schema.define do
      create_table "streets" do |t|
        t.column "name", :string, :limit => 40
        t.column "socr", :string, :limit => 10
        t.column "code", :string, :limit => 17
        t.column "index", :string, :limit => 6
        t.column "gninmb", :string, :limit => 4
        t.column "uno", :string, :limit => 4
        t.column "ocatd", :string, :limit => 11
      end
    end
  end


  def Kladr_sqlite.save_linked( kladr_name, streets_name, db_name, progress )
    kladr = DBF::Table.new( kladr_name )
    streets = DBF::Table.new( streets_name )

    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :dbfile  => db_name,
      :database => db_name
    )

    create_linked_tables
    @converter = Iconv.new( 'UTF-8//IGNORE', 'CP866' )

    if progress then
      kladr_bar = ProgressBar.new( 'KLADR loading', kladr.count )
      street_bar = ProgressBar.new( 'Streets loading', streets.count )
    end

    streets.each do |record|
      street = Kladr.create( :name => @converter.iconv( record.name ),
                              :socr => @converter.iconv( record.socr ),
                              :code => get_city_code( @converter.iconv( record.code ) ) )
      if progress then
        kladr_bar.inc
      end
    end

    kladr.each do |record|
      code = @converter.iconv( record.code )
      if ( is_city( code ) ) then
        name = @converter.iconv( record.name )
        socr = @converter.iconv( record.socr )
        city = City.create( :name => name,
                            :socr => socr )

        streets = Kladr.all( :conditions => "code = '#{code}'" )

        if streets.count != 0 then
          streets.each do |street|
            city.streets.create( :name => street.name,
                                    :socr => street.socr)
          end
        end
        Kladr.delete_all( "code = '#{code}'" )
      end
    end

  end

  def Kladr_sqlite.save_raw( kladr_name, streets_name, db_name, progress )
    kladr = DBF::Table.new( kladr_name )
    streets = DBF::Table.new( streets_name )

    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :dbfile  => db_name,
      :database => db_name
    )

    create_raw_tables
    @converter = Iconv.new( 'UTF-8//IGNORE', 'CP866' )

    if progress then
      kladr_bar = ProgressBar.new( 'KLADR loading', kladr.count )
      street_bar = ProgressBar.new( 'Streets loading', streets.count )
    end

    kladr.each do |record|
      kladr = Kladr.create( :name => @converter.iconv( record.name ),
                            :socr => @converter.iconv( record.socr ),
                            :code => get_city_code( @converter.iconv( record.code ) ),
                            :index => @converter.iconv( record.index ),
                            :gninmb => @converter.iconv( record.gninmb ),
                            :uno => @converter.iconv( record.uno ),
                            :ocatd => @converter.iconv( record.ocatd ),
                            :status => @converter.iconv( record.status ) )
      if progress then
        kladr_bar.inc
      end
    end

    streets.each do |record|
      street = Kladr_street.create( :name => @converter.iconv( record.name ),
                              :socr => @converter.iconv( record.socr ),
                              :code => @converter.iconv( record.code ),
                              :index => @converter.iconv( record.index ),
                              :gninmb => @converter.iconv( record.gninmb ),
                              :uno => @converter.iconv( record.uno ),
                              :ocatd => @converter.iconv( record.ocatd ) )
      street_bat.inc
    end

  end
end
