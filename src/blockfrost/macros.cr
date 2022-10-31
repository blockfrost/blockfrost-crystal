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
end
