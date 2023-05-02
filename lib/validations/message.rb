module Validations
  class Message
    # @errors [Hash | Array] output of dry-validation
    #         after validating params
    # @parent [Nil | String] key name of a field that has `errors`
    #         after validating params
    # Output: array of string that can be used to feed into
    # Errors::InvalidParamsError
    def build(errors, parent = nil)
      case errors
      when Hash
        errors.flat_map do |key, value|
          child = [parent, key].compact.join(' ')
          build(value, child)
        end
      when Array
        errors.flat_map do |error|
          build(error)
        end.map do |error|
          "#{parent.to_s.titleize} #{error}"
        end
      else
        errors
      end
    end
  end
end
