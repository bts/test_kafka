require 'fileutils'
require 'test_kafka/cluster_runner'

module TestKafka
  def self.start(kafka_path, tmp_dir='/tmp', kafka_port=9092, zk_port=2181)
    FileUtils.rm_rf(tmp_dir)

    TestKafka::ClusterRunner.new(kafka_path, tmp_dir, kafka_port, zk_port).start
  end
end
