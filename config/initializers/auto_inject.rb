class DependencyInjectionContainer
  extend Dry::Container::Mixin

  register('create_table') do
    Scylla::QueryHandlers::CreateTable.new
  end

  register('batch_insert') do
    Scylla::QueryHandlers::BatchInsert.new
  end

  register('select') do
    Scylla::QueryHandlers::Select.new
  end

  register('fetch_table') do
    Interactors::FetchTable.new
  end

  register('message_queue') do
    MessageQueue.new
  end
end

Dependency = Dry::AutoInject(DependencyInjectionContainer)
