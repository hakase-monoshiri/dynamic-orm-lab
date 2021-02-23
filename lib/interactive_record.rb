require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord


    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true
      
        sql = "PRAGMA table_info('#{table_name}')"
      
        table_info = DB[:conn].execute(sql)
        column_names = []
      
        table_info.each do |column|
          column_names << column["name"]
        end
      
        column_names.compact
    end 

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        names = self.class.column_names.delete_if {|col| col == "id"}
        names.join(", ")
    end
  
    def values_for_insert
        values = []
        self.class.column_names.map do |attribute_key|
            values << "'#{send(attribute_key)}'" unless send(attribute_key).nil?
        end
        values.join(", ")
    end

    def save
        sql = <<-SQL
            INSERT INTO #{table_name_for_insert}
            (#{col_names_for_insert})
            VALUES (#{values_for_insert});
        SQL
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name(name)
        DB[:conn].results_as_hash = true
        sql = <<-SQL
            SELECT * FROM #{table_name}
            WHERE name = ? 
        SQL
        found_hash = DB[:conn].execute(sql, name)
    end

    def self.find_by(attributes_hash)
        DB[:conn].results_as_hash = true
        k = attributes_hash.keys.first.to_s
        v = attributes_hash[k.to_sym].to_s
        sql = <<-SQL
            SELECT * FROM #{table_name}
            WHERE #{k} = ?;
        SQL
        found_student = DB[:conn].execute(sql, "#{v}")
        # binding.pry
    end




end