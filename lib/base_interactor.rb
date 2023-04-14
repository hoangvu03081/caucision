class BaseInteractor
  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:call)
end
