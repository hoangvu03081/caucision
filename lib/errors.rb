module Errors
  class BaseError < StandardError
    attr_reader :code

    def self.code(code_string)
      define_method(:code) { code_string }
      const_set('CODE', code_string)
    end

    def self.default_message(message)
      define_method(:default_message) { message }
    end

    def initialize(message = default_message)
      super(message)
    end

    def to_h
      {
        message:,
        code:
      }
    end

    def to_json(*)
      to_h.to_json
    end

    def ==(other)
      super && code == other.code
    end
  end

  class InvalidParamsError < BaseError
    code 'CA1001'
    default_message 'Invalid params'
  end

  class NotFoundError < BaseError
    code 'CA1002'
    default_message 'Resource not found'

    def self.build(model, id)
      new("Resource not found: #{model.name} #{id}")
    end
  end
end
