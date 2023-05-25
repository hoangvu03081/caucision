class MessageQueue
  QUEUE_TO_CELERY_TASK_MAPPINGS = {
    Constants::Queue::DATA_IMPORTED => 'train_model'
  }.freeze

  def initialize
    @conn = Bunny.new(host: ENV.fetch('RABBIT_MQ_HOST'))
  end

  def direct_publish(queue_name, payload)
    conn.start

    ch = conn.create_channel
    queue = ch.queue(queue_name, durable: true, auto_delete: false)

    prepared_payload = format_celery_message(queue_name, payload)
    queue.publish(prepared_payload, content_type: 'application/json')

    conn.close
  end

  private

    attr_reader :conn

    def format_celery_message(queue_name, payload)
      {
        id: SecureRandom.uuid,
        task: QUEUE_TO_CELERY_TASK_MAPPINGS[queue_name],
        args: [payload]
      }.to_json
    end
end
