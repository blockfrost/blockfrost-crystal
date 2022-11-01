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

    def self.{{method_name.id}}_within_page_range(
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
          page: item
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

    {% unless argument_type_declaration.nil? %}
      def {{method_name.id}}(**args)
        self.class.{{method_name.id}}({{argument_type_declaration.var}}, **args)
      end
    {% end %}
  end

  macro within_page_range(pages, return_type, method_name, method_arguments)
    fetch = ->(tries : Int32, item : Int32, i : Int32) {}
    sleep_retries = Blockfrost.settings.sleep_between_retries_ms / 1000.0
    channel = Channel({Int32, {{return_type}}?}).new
    results = ([nil] of {{return_type}}?) * pages.size

    fetch = ->(tries : Int32, item : Int32, i : Int32) do
      channel.send({i, {{method_name.id}}(**{{method_arguments}})})
    rescue e : Blockfrost::Client::OverLimitException
      if tries < MAX_RETRIES_IN_PARALLEL_REQUESTS
        sleep sleep_retries
        fetch.call(tries.succ, item, i)
      else
        channel.send({i, nil})
      end
    end

    pages.each.with_index do |item, i|
      spawn { fetch.call(0, item, i) }
      channel.receive.tap {|r| results[r.first] = r.last }
    end

    !results.includes?(nil) ||
      raise Blockfrost::AccountLimitedException.new("Please, try again later")

    results.compact.reduce({{return_type}}.new) { |a, r| a.tap { a.concat(r) } }
  end
end
