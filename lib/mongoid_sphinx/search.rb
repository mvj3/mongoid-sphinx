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
      matches.each_with_index do |match, index|
        yield match, document_map[document_ids[index]]
      end
    end
    alias :each_hit_with_result :each_match_with_result

    def matches
      raw_result[:matches]
    end
    alias :hits :matches

    def document_ids
      @document_ids ||= matches.collect do |match|
        (100000000000000000000000 + match[:doc]).to_s
      end
    end

    def document_map
      @document_map = model.find(document_ids).inject({}) { |memo, d| memo[d.id] = d; memo }
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