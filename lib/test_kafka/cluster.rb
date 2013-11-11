require 'test_kafka/zookeeper'
require 'test_kafka/broker'

module TestKafka
  class Cluster
    def initialize(kafka_path, tmp_dir, kafka_port, zk_port)
      @zookeeper = Zookeeper.new(kafka_path, tmp_dir, zk_port)
      @broker = Broker.new(kafka_path, tmp_dir, kafka_port, zk_port)
    end

    attr_reader :broker, :zookeeper

    def start
      @zookeeper.start
      @broker.start

      self
    end

    def stop
      @zookeeper.stop
      @broker.stop

      self
    end

    def with_interruption(&block)
      @broker.with_interruption(&block)
    end
  end
end
