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

  describe '#pid' do
    it 'is the PID of the ZK process' do
      server.start
      ps_output = `ps aux |
          grep zookeeper |
          grep #{Regexp.escape(tmp_dir)} |
          grep -v grep`
      ps_pid = ps_output[/(\d+)/, 1].to_i

      server.pid.should eql ps_output[/(\d+)/, 1].to_i

      server.stop
    end
  end

  def running?(pid)
    Process.kill(0, pid)
    true
  rescue Errno::ESRCH
    false
  end

  describe '#stop' do
    it 'stops a running ZK server' do
      server.start
      pid = server.pid
      server.stop

      running?(pid).should be_false
    end
  end

  describe '#port' do
    it 'is the provided port' do
      server.port.should eql port
    end
  end

  describe '#with_interruption' do
    it 'temporarily stops the server' do
      server.start
      old_pid = server.pid

      server.with_interruption do
        running?(old_pid).should be_false
      end
      new_pid = server.pid

      running?(new_pid).should be_true

      server.stop
    end
  end
end
