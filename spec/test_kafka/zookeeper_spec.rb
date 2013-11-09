require 'spec_helper'
require 'test_kafka/zookeeper'
require 'zk'
require 'fileutils'

describe TestKafka::Zookeeper do
  let(:port) { 2182 }
  let(:tmp_dir) { "/tmp/zk-test" }
  let(:server) { TestKafka::Zookeeper.new(KAFKA_PATH, tmp_dir, port) }

  before do
    FileUtils.rm_rf(tmp_dir)
  end

  describe '#start' do
    it 'starts a ZK server' do
      server.start

      client = ZK.new("localhost:#{port}")
      begin
        client.create("/path", "foo")
      rescue ZK::Exceptions::OperationTimeOut
        sleep 0.1
        retry
      end
      client.get("/path").first.should eql "foo"

      server.stop
    end
  end

  describe '#stop' do
    it 'stops a running ZK server'
  end

  describe '#pid'
  describe '#port'
  describe '#with_interruption'
end
