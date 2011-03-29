module MongoidSphinx
  class Search
    attr_reader :raw_result
    attr_reader :model

    def initialize(model, raw_result)
      @model = model
      @raw_result = raw_result
    end

    def each_match_with_result
      documents.each_with_index do |document, index|
        yield matches[index], document
      end
    end
    alias :each_hit_with_result :each_match_with_result

    def matches
      raw_result[:matches]
    end
    alias :hits :matches

    def document_ids
      @document_ids ||= matches.collect do |row|
        (100000000000000000000000 + row[:doc]).to_s rescue nil
      end.compact
    end

    def documents
      @documents ||= model.find(document_ids)
    end
  end
end