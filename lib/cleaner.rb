require 'set'

module Cleaner
    NAME_PATTERN = /([a-z_][a-z0-9_]*(?:(?:\.|->|::)[a-z_][a-z0-9_]*)*)/i
    VARIABLE_PATTERN = /(?:@|$|&|\*)?#{NAME_PATTERN}(?:\[.*\])?/
    VARIABLE_ASSIGNMENT_PATTERN = /#{VARIABLE_PATTERN}((?:\s*,\s*#{VARIABLE_PATTERN})*)\s*(?::=|=|<-)/
    FUNCTION_DEFINITION_PATTERN = /(?:def(?:ine|un)?|func?(?:tion)?)\s+#{NAME_PATTERN}/
    CLASS_LIKE_DEFINITION_PATTERN = /(?:class|namespace|module|interface|struct)\s+#{NAME_PATTERN}/

    def self.clean_whitespace(string, removed = [])
        result = ''
        string.chars.each_with_index do |c, i| 
            unless c =~ /\s/
                result << c.downcase
            else
                removed << result.size
            end
        end

        [result, removed]
    end

    def self.clean_accents(string, removed = [])
        result = string.tr(
            "ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž",
            "AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz"
        )

        [result, removed]
    end

    def self.replace_tokens(tokens, replacement, string, removed = [])
        result = string
        for t in tokens
            i = 0
            loop do
                i = result.index(/\b#{t}\b/, i)
                break if i.nil?
                result[i, t.size] = '_'
                (t.size - 1).times {|j| removed << i + j + 1 }
            end
        end

        [result, removed]
    end

    def self.clean_functions(string, removed = [])
        functions = Set.new

        string.scan(FUNCTION_DEFINITION_PATTERN) do |f|
            functions.add(f[0])
        end

        replace_tokens(functions, '_', string, removed)
    end

    def self.clean_class_like(string, removed = [])
        classlike = Set.new

        string.scan(CLASS_LIKE_DEFINITION_PATTERN) do |c|
            classlike.add(c[0])
        end

        replace_tokens(classlike, '_', string, removed)
    end

    def self.clean_variables(string, removed = [])
        variables = Set.new

        string.scan(VARIABLE_ASSIGNMENT_PATTERN) do |var|
            variables.add(var[0])
            unless var[1].nil?
                var[1].scan(VARIABLE_PATTERN) do |var2|
                    variables.add(var2[0])
                end
            end
        end

        replace_tokens(variables, '_', string, removed)
    end

    def self.parse(string)
        result, removed = string, []
        result, removed = clean_accents result, removed
        result, removed = clean_variables result, removed
        result, removed = clean_functions result, removed
        result, removed = clean_class_like result, removed
        result, removed = clean_whitespace result, removed
        [result, removed]
    end
end