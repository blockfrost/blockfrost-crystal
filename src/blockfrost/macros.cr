module Blockfrost
  macro enum_castable_from_string(name, types, stringify = underscore)
    enum {{name}}
      {% for type in types %}
        {{type}}
      {% end %}

      def to_s
        super.{{stringify}}
      end

      def self.from_json(pull : JSON::PullParser)
        from_string(pull.read_string.to_s)
      end

      def self.from_string(value : String)
        from_value(names.map(&.{{stringify}}).index(value) || 0)
      end
    end
  end

  macro gets_all_with_pagination(
    method_name,
    return_type,
    resource_path,
    argument_type_declaration
  )
    def self.{{method_name.id}}(
      {{argument_type_declaration}},
      count : Int32? = nil,
      page : Int32? = nil
    )
      {{return_type}}.from_json(
        Client.get({{resource_path}}, {
          "count" => count || Blockfrost.settings.default_count_per_page,
          "page" => page
        })
      )
    end

    def {{method_name.id}}(**args)
      self.class.{{method_name.id}}({{argument_type_declaration.var}}, **args)
    end
  end

  macro gets_all_scoped_with_pagination(
    method_name,
    return_type,
    resource_path,
    argument_type_declaration,
    scope_argument_type_declaration
  )
    def self.{{method_name.id}}(
      {{argument_type_declaration}},
      {{scope_argument_type_declaration}},
      count : Int32? = nil,
      page : Int32? = nil
    )
      {{return_type}}.from_json(
        Client.get({{resource_path}}, {
          "count" => count || Blockfrost.settings.default_count_per_page,
          "page" => page
        })
      )
    end

    def {{method_name.id}}(
      {{scope_argument_type_declaration}},
      **args
    )
      self.class.{{method_name.id}}(
        {{argument_type_declaration.var}},
        {{scope_argument_type_declaration.var}},
        **args
      )
    end
  end

  macro gets_all_with_order_and_pagination(
    method_name,
    return_type,
    resource_path,
    argument_type_declaration = nil
  )
    def self.{{method_name.id}}(
      {% unless argument_type_declaration.nil? %}
        {{argument_type_declaration}},
      {% end %}
      order : QueryOrder? = nil,
      count : Int32? = nil,
      page : Int32? = nil
    )
      {{return_type}}.from_json(
        Client.get({{resource_path}}, {
          "order" => (order || Blockfrost.settings.default_order).try(&.to_s),
          "count" => count || Blockfrost.settings.default_count_per_page,
          "page"  => page,
        })
      )
    end

    def self.{{method_name.id}}(
      {% unless argument_type_declaration.nil? %}
        {{argument_type_declaration}},
      {% end %}
      order : String,
      count : Int32? = nil,
      page : Int32? = nil
    )
      {{method_name.id}}(
        {% unless argument_type_declaration.nil? %}
          {{argument_type_declaration.var}},
        {% end %}
        QueryOrder.from_string(order),
        count,
        page
      )
    end

    def self.{{method_name.id}}(
      {% unless argument_type_declaration.nil? %}
        {{argument_type_declaration}},
      {% end %}
      pages : Range,
      order : QueryOrder | String? = nil
    )
      Blockfrost.within_page_range(pages, {{return_type}}, {{method_name}}, {
        {% unless argument_type_declaration.nil? %}
        {{argument_type_declaration.var}}: {{argument_type_declaration.var}},
        {% end %}
        order: order,
        page: page
      })
    end

    {% unless argument_type_declaration.nil? %}
      def {{method_name.id}}(**args)
        self.class.{{method_name.id}}({{argument_type_declaration.var}}, **args)
      end
    {% end %}
  end

  macro gets_all_scoped_with_order_and_pagination(
    method_name,
    return_type,
    resource_path,
    argument_type_declaration,
    scope_argument_type_declaration
  )
    def self.{{method_name.id}}(
      {{argument_type_declaration}},
      {{scope_argument_type_declaration}},
      order : QueryOrder? = nil,
      count : Int32? = nil,
      page : Int32? = nil
    )
      {{return_type}}.from_json(
        Client.get({{resource_path}}, {
          "order" => (order || Blockfrost.settings.default_order).try(&.to_s),
          "count" => count || Blockfrost.settings.default_count_per_page,
          "page"  => page,
        })
      )
    end

    def self.{{method_name.id}}(
      {{argument_type_declaration}},
      {{scope_argument_type_declaration}},
      order : String,
      count : Int32? = nil,
      page : Int32? = nil
    )
      {{method_name.id}}(
        {{argument_type_declaration.var}},
        {{scope_argument_type_declaration.var}},
        QueryOrder.from_string(order),
        count,
        page
      )
    end

    def self.{{method_name.id}}(
      {{argument_type_declaration}},
      {{scope_argument_type_declaration}},
      pages : Range,
      order : QueryOrder | String? = nil
    )
      Blockfrost.within_page_range(pages, {{return_type}}, {{method_name}}, {
        {{argument_type_declaration.var}}: {{argument_type_declaration.var}},
        {{scope_argument_type_declaration.var}}: {{scope_argument_type_declaration.var}},
        order: order,
        page: page
      })
    end

    {% unless argument_type_declaration.nil? %}
      def {{method_name.id}}(
        {{scope_argument_type_declaration.var}},
        **args
      )
        self.class.{{method_name.id}}(
          {{argument_type_declaration.var}},
          {{scope_argument_type_declaration.var}},
          **args
        )
      end
    {% end %}
  end

  macro gets_all_with_order_and_pagination_and_from_to(
    method_name,
    return_type,
    resource_path,
    argument_type_declaration = nil
  )
    def self.{{method_name.id}}(
      {% unless argument_type_declaration.nil? %}
        {{argument_type_declaration}},
      {% end %}
      order : QueryOrder? = nil,
      count : Int32? = nil,
      page : Int32? = nil,
      from : String? = nil,
      to : String? = nil
    )
      {{return_type}}.from_json(
        Client.get({{resource_path}}, {
          "order" => (order || Blockfrost.settings.default_order).try(&.to_s),
          "count" => count || Blockfrost.settings.default_count_per_page,
          "page"  => page,
          "from"  => from,
          "to"    => to,
        })
      )
    end

    def self.{{method_name.id}}(
      {% unless argument_type_declaration.nil? %}
        {{argument_type_declaration}},
      {% end %}
      order : String,
      count : Int32? = nil,
      page : Int32? = nil,
      from : String? = nil,
      to : String? = nil
    )
      {{method_name.id}}(
        {% unless argument_type_declaration.nil? %}
          {{argument_type_declaration.var}},
        {% end %}
        QueryOrder.from_string(order),
        count,
        page,
        from,
        to
      )
    end

    def self.{{method_name.id}}(
      {% unless argument_type_declaration.nil? %}
        {{argument_type_declaration}},
      {% end %}
      pages : Range,
      order : QueryOrder | String? = nil,
      from : String? = nil,
      to : String? = nil
    )
      Blockfrost.within_page_range(pages, {{return_type}}, {{method_name}}, {
        {{argument_type_declaration.var}}: {{argument_type_declaration.var}},
        order: order,
        page: page,
        from: from,
        to: to
      })
    end

    {% unless argument_type_declaration.nil? %}
      def {{method_name.id}}(**args)
        self.class.{{method_name.id}}({{argument_type_declaration.var}}, **args)
      end
    {% end %}
  end

  # The Blockfrost API imposes a limit of 100 records per page for a single
  # request. This macro allows fetching multiple pages concurrently. It then
  # concatenates all results in the correct order and returns an array of
  # records as if fetched in one go.
  #
  # It also handles all possible exceptions. If the account is temporarily
  # rate-limited, it will retry several times, as defined by
  # `MAX_RETRIES_IN_CONCURRENT_REQUESTS` in the scr/settings.cr. All other
  # exceptions will cause immediate failure by raising the first encountered
  # exception.
  macro within_page_range(pages, return_type, method_name, method_arguments)
    pages.size <= (max = MAX_NUMBER_OF_CONCURRENT_REQUESTS) ||
      raise ConcurrencyLimitException.new("Too many concurrent requests.")

    # rate limiting settings
    sleep_retries = Blockfrost.settings.sleep_between_retries_ms / 1000.0
    max_retries = Blockfrost.settings.retries_in_concurrent_requests

    # stores for results and/or exceptions
    results = ([nil] of {{return_type}}?) * pages.size
    exceptions = [] of Exception

    fetch = ->(tries : Int32, page : Int32, i : Int32) {}
    channel = Channel({Int32, Exception?, {{return_type}}?}).new

    # proc for recursive calling with retries
    fetch = ->(tries : Int32, page : Int32, i : Int32) do
      channel.send({i, nil, {{method_name.id}}(**{{method_arguments}})})
    rescue e : Client::OverLimitException
      if tries < max_retries
        sleep sleep_retries
        fetch.call(tries.succ, page, i)
      else
        channel.send({i, e, nil})
      end
    rescue e : Exception
      channel.send({i, e, nil})
    end

    # spawn fibers
    pages.each.with_index do |page, i|
      spawn do
        fetch.call(0, page, i)
      end
    end

    # receive results
    pages.each do
      i, e, result = channel.receive
      e ? exceptions << e : (results[i] = result)
    end

    exceptions.empty? || raise exceptions.first

    # concatenate all resulting arrays
    results.compact.reduce({{return_type}}.new) { |a, r| a.tap { a.concat(r) } }
  end
end
