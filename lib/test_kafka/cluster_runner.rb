require 'test_kafka/zookeeper_runner'
require 'test_kafka/broker_runner'

module TestKafka
  class ClusterRunner
    def initialize(kafka_path, tmp_dir, kafka_port, zk_port)
      @zookeeper = ZookeeperRunner.new(kafka_path, tmp_dir, zk_port)
      @broker = BrokerRunner.new(kafka_path, tmp_dir, 0, kafka_port, zk_port)
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
  end
end
