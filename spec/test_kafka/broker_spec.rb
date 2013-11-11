require 'spec_helper'
require 'test_kafka/broker'
require 'test_kafka/zookeeper'

describe TestKafka::Broker do
  let(:broker_port) { 9093 }
  let(:zk_port) { 2182 }
  let(:broker_tmp_dir) { "/tmp/kafka-test" }
  let(:broker) { TestKafka::Broker.new(KAFKA_PATH,
                                       broker_tmp_dir,
                                       broker_port,
                                       zk_port) }

  before(:all) do
    zk_tmp_dir = "/tmp/zk-test"
    FileUtils.rm_rf(zk_tmp_dir)
    @zk = TestKafka::Zookeeper.new(KAFKA_PATH, zk_tmp_dir, zk_port)
    @zk.start
  end

  after(:all) do
    @zk.stop
  end

  before do
    FileUtils.rm_rf(broker_tmp_dir)
  end

  describe '#start' do
    it 'starts a Kafka broker' do
      broker.start
      messages = ['value1', 'value2']
      write_messages(broker_port, messages)

      read_messages(broker_port).should eql messages

      broker.stop
    end
  end

  describe '#pid' do
    it 'is the PID of the broker process' do
      broker.start
      ps_output = `ps aux |
          grep "kafka\\.Kafka" |
          grep #{Regexp.escape(broker_tmp_dir)} |
          grep -v grep`
      ps_pid = ps_output[/(\d+)/, 1].to_i

      broker.pid.should eql ps_output[/(\d+)/, 1].to_i

      broker.stop
    end
  end

  describe '#stop' do
    it 'stops a running Kafka broker' do
      broker.start
      pid = broker.pid
      broker.stop

      running?(pid).should be_false
    end
  end

  describe '#port' do
    it 'is the provided port' do
      broker.port.should eql broker_port
    end
  end

  describe '#with_interruption' do
    it 'temporarily drops the broker' do
      broker.start
      old_pid = broker.pid

      broker.with_interruption do
        running?(old_pid).should be_false
      end
      new_pid = broker.pid

      running?(new_pid).should be_true

      broker.stop
    end
  end
end
