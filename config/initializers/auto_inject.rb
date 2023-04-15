class DependencyInjectionContainer
  extend Dry::Container::Mixin

  register('create_table') do
    Scylla::QueryHandlers::CreateTable.new
  end

  register('batch_insert') do
    Scylla::QueryHandlers::BatchInsert.new
  end
end

Dependency = Dry::AutoInject(DependencyInjectionContainer)
