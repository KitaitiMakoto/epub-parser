class ForwardableDefDelegatorsHandler < YARD::Handlers::Ruby::Base
  handles method_call(:def_delegators)
  namespace_only

  def process
    params = validated_attribute_names(statement.parameters(false))
    accessor = params.shift
    params.each do |param|
      object = YARD::CodeObjects::MethodObject.new(namespace, param)
      object.docstring = "Forwarded to +#{accessor}+"
    end
  end

  protected

  # Strips out any non-essential arguments from the attr statement.
  #
  # @param [Array<Parser::Ruby::AstNode>] params a list of the parameters
  #   in the attr call.
  # @return [Array<String>] the validated attribute names
  # @raise [Parser::UndocumentableError] if the arguments are not valid.
  def validated_attribute_names(params)
    params.map do |obj|
      case obj.type
      when :symbol_literal
        obj.jump(:ident, :op, :kw, :const).source
      when :string_literal
        obj.jump(:string_content).source
      else
        raise YARD::Parser::UndocumentableError, obj.source
      end
    end
  end
end
