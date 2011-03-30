module MongoidSphinx
  class Search
    attr_reader :client
    attr_reader :model
    attr_reader :raw_result

    def initialize(client, model, raw_result)
      @client = client
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

    def total_pages
      (raw_result[:total] / client.limit).ceil
    end

    def per_page
      client.limit
    end

    def current_page
      (client.offset / client.limit) + 1
    end

    def previous_page
       (p = current_page - 1) == 0 ? nil : p
    end

    def next_page
      current_page == total_pages ? nil : current_page + 1
    end
  end
end