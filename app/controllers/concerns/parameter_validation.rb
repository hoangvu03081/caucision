module ParameterValidation
  extend ActiveSupport::Concern

  included do
    class_attribute :parameter_schemas, instance_writer: false, default: {}
    before_action :validate_parameters, prepend: true
  end

  class_methods do
    def contract_for(action, &)
      schema = Dry::Validation.Contract do
        instance_exec(&)
      end

      parameter_schemas["#{controller_path}##{action}"] = schema
    end

    def params_for(*actions, &)
      schema = Dry::Schema.Params do
        instance_exec(&)
      end

      actions.each { |action| parameter_schemas["#{controller_path}##{action}"] = schema }
    end
  end

  private

    attr_reader :validated_parameters

    def params
      if validated_parameters
        ActionController::Parameters.new(validated_parameters).permit!
      else
        super
      end
    end

    def validate_parameters
      schema = parameter_schemas["#{controller_path}##{action_name}"]

      return if schema.blank?

      validation = schema.call(request.params)

      if validation.success?
        @validated_parameters = validation.to_h
      else
        message = validation.errors.messages.map do |m|
          "#{m.path.join('->')}: #{m}"
        end.join(', ')
        render_errors ::Errors::InvalidParamsError.new(message)
      end
    end
end
