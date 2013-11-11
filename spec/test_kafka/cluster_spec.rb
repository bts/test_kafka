require 'spec_helper'
require 'test_kafka/cluster'
require 'poseidon'

describe TestKafka::Cluster do
  let(:tmp_dir) { "/tmp/cluster-test" }
  let(:broker_port) { 9093 }
  let(:zk_port) { 2182 }
  let(:cluster) { TestKafka::Cluster.new(KAFKA_PATH, tmp_dir, broker_port, zk_port) }

  before do
    FileUtils.rm_rf(tmp_dir)
  end

  describe '#start' do
    it 'starts the cluster' do
      cluster.start
      messages = ['value1', 'value2']
      write_messages(broker_port, messages)

      read_messages(broker_port).should eql messages

      cluster.stop
    end
  end

  describe '#stop' do
    it 'stops a running cluster' do
      cluster.start
      broker_pid = cluster.broker.pid
      zk_pid = cluster.zookeeper.pid
      cluster.stop

      running?(broker_pid).should be_false
      running?(zk_pid).should be_false
    end
  end

  describe '#with_interruption' do
    it 'temporarily stops the kafka broker' do
      cluster.start
      old_broker_pid = cluster.broker.pid
      old_zk_pid = cluster.zookeeper.pid

      cluster.with_interruption do
        running?(old_broker_pid).should be_false
      end
      new_broker_pid = cluster.broker.pid

      running?(new_broker_pid).should be_true
      running?(old_zk_pid).should be_true

      cluster.stop
    end
  end
end
