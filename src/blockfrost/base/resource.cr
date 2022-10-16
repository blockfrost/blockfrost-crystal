abstract struct Blockfrost::BaseResource
  include JSON::Serializable

  def self.client : Client
    Client.new
  end

  def self.order_from_string(order : String?) : QueryOrder?
    return unless order

    QueryOrder.from_string(order)
  end

  macro gets_all_with_pagination(
    method_name,
    return_type,
    resource_path,
    argument_type_declaration
  )
    def self.{{method_name.id}}(
      {{argument_type_declaration}},
      count : QueryCount? = nil,
      page : QueryPage? = nil
    ) : {{return_type}}
      {{return_type}}.from_json(
        client.get({{resource_path}}, {
          "count" => count,
          "page" => page
        })
      )
    end

    def {{method_name.id}}(**args) : {{return_type}}
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
      count : QueryCount? = nil,
      page : QueryPage? = nil
    ) : {{return_type}}
      {{return_type}}.from_json(
        client.get({{resource_path}}, {
          "count" => count,
          "page" => page
        })
      )
    end

    def {{method_name.id}}(
      {{scope_argument_type_declaration}},
      **args
    ) : {{return_type}}
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
      count : QueryCount? = nil,
      page : QueryPage? = nil
    ) : {{return_type}}
      {{return_type}}.from_json(
        client.get({{resource_path}}, {
          "order" => order.try(&.to_s),
          "count" => count,
          "page"  => page,
        })
      )
    end

    def self.{{method_name.id}}(
      {% unless argument_type_declaration.nil? %}
        {{argument_type_declaration}},
      {% end %}
      order : String,
      count : QueryCount? = nil,
      page : QueryPage? = nil
    ) : {{return_type}}
      {{method_name.id}}(
        {% unless argument_type_declaration.nil? %}
          {{argument_type_declaration.var}},
        {% end %}
        order_from_string(order),
        count,
        page
      )
    end

    {% unless argument_type_declaration.nil? %}
      def {{method_name.id}}(**args) : {{return_type}}
        self.class.{{method_name.id}}({{argument_type_declaration.var}}, **args)
      end
    {% end %}
  end
end
