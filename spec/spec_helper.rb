RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  # config.run_all_when_everything_filtered = true
  # config.filter_run :focus
  config.order = 'random'
end

DEFAULT_KAFKA_PATH = "/usr/local/kafka"
KAFKA_PATH = ENV["KAFKA_PATH"] || DEFAULT_KAFKA_PATH

require 'test_kafka/java_runner'

if Dir.glob(KAFKA_PATH + "/" + TestKafka::JavaRunner::JAR_PATTERN).empty?
  fail "Could not find Kafka. Set the environment variable KAFKA_PATH or install Kafka to /usr/local/kafka."
end
