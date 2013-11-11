require 'spec_helper'
require 'test_kafka'
require 'fileutils'

describe TestKafka do
  describe '.start' do
    context 'with custom args' do
      let(:tmp_root) { '/tmp/test_kafka-test' }
      let(:broker_port) { 9093 }
      let(:zk_port) { 2182 }

      it 'initializes and starts a single-node test cluster' do
        cluster = TestKafka.start(KAFKA_PATH, tmp_root, broker_port, zk_port)

        messages = ['value1', 'value2']
        write_messages(broker_port, messages)

        read_messages(broker_port).should eql messages

        cluster.stop
      end

      it 'deletes an existing test_kafka temp directory if one exists' do
        tmp_dir = tmp_root + "/test_kafka"
        FileUtils.mkdir_p(tmp_dir)
        canary_path = tmp_dir + "/canary"
        File.write(canary_path, "chirp")

        cluster = TestKafka.start(KAFKA_PATH, tmp_root, broker_port, zk_port)

        File.exist?(canary_path).should be_false

        cluster.stop
      end
    end

    context 'with default args' do
      before(:all) { @cluster = TestKafka.start(KAFKA_PATH) }
      after(:all) { @cluster.stop }

      it 'uses /tmp as a temp root' do
        Dir.exist?('/tmp/test_kafka').should be_true
      end

      it 'uses kafka port 9092' do
        @cluster.broker.port.should eql 9092
      end

      it 'uses ZK port 2181' do
        @cluster.zookeeper.port.should eql 2181
      end
    end
  end
end
