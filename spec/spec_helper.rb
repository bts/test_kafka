RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  # config.run_all_when_everything_filtered = true
  # config.filter_run :focus
  config.order = 'random'
end

DEFAULT_KAFKA_PATH = "/usr/local/kafka"
KAFKA_PATH = ENV["KAFKA_PATH"] || DEFAULT_KAFKA_PATH

require 'test_kafka/java_runner'

jar_paths = TestKafka::JavaRunner::JAR_PATTERNS.flat_map { |pat|
  Dir.glob(KAFKA_PATH + "/" + pat)
}

if jar_paths.empty?
  fail "Could not find Kafka JARs. Set the environment variable KAFKA_PATH or install Kafka to /usr/local/kafka."
end

def running?(pid)
  Process.kill(0, pid)
  true
rescue Errno::ESRCH
  false
end

require 'poseidon'

def write_messages(port, messages)
  producer = Poseidon::Producer.new(["localhost:#{port}"],
                                    'test_producer')
  producer.send_messages(messages.map { |m|
    Poseidon::MessageToSend.new('topic1', m)
  })
end

def read_messages(port)
  consumer = Poseidon::PartitionConsumer.new(
    'test_consumer',
    'localhost',
    broker_port,
    'topic1',
    0,
    :earliest_offset
  )

  consumer.fetch.map(&:value)
end
