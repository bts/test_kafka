require 'fileutils'
require 'test_kafka/cluster'

module TestKafka
  def self.start(kafka_path, tmp_root='/tmp', kafka_port=9092, zk_port=2181)
    tmp_dir = tmp_root + "/test_kafka"
    FileUtils.rm_rf(tmp_dir)

    TestKafka::Cluster.new(kafka_path, tmp_dir, kafka_port, zk_port).start
  end
end
