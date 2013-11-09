require 'test_kafka/java_runner'

module TestKafka
  class Zookeeper
    def initialize(kafka_path, tmp_dir, port)
      @jr = JavaRunner.new("zookeeper",
                           tmp_dir,
                           "org.apache.zookeeper.server.quorum.QuorumPeerMain",
                           port,
                           kafka_path,
                           :dataDir => "#{tmp_dir}/zookeeper",
                           :clientPort => port,
                           :maxClientCnxns => 0)
    end

    def pid
      @jr.pid
    end

    def start
      @jr.start
    end

    def stop
      @jr.stop
    end

    def with_interruption
      @jr.with_interruption { yield }
    end
  end
end
