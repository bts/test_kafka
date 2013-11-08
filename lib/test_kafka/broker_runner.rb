require 'test_kafka/java_runner'

module TestKafka
  class BrokerRunner
    DEFAULT_PROPERTIES = {
      "broker.id" => 0,
      "port" => 9092,
      "num.network.threads" => 2,
      "num.io.threads" => 2,
      "socket.send.buffer.bytes" => 1048576,
      "socket.receive.buffer.bytes" => 1048576,
      "socket.request.max.bytes" => 104857600,
      "log.dir" => "/tmp/kafka-logs",
      "num.partitions" => 1,
      "log.flush.interval.messages" => 10000,
      "log.flush.interval.ms" => 1000,
      "log.retention.hours" => 168,
      "log.segment.bytes" => 536870912,
      "log.cleanup.interval.mins" => 1,
      "zookeeper.connect" => "localhost:2181",
      "zookeeper.connection.timeout.ms" => 1000000,
      "kafka.metrics.polling.interval.secs" => 5,
      "kafka.metrics.reporters" => "kafka.metrics.KafkaCSVMetricsReporter",
      "kafka.csv.metrics.dir" => "/tmp/kafka_metrics",
      "kafka.csv.metrics.reporter.enabled" => "false",
    }

    def initialize(kafka_path, tmp_dir, id, port, zk_port, partition_count = 1)
      @id = id
      @port = port
      @jr = JavaRunner.new("broker_#{id}",
                           tmp_dir,
                           "kafka.Kafka",
                           port,
                           kafka_path,
                           DEFAULT_PROPERTIES.merge(
                             "broker.id" => id,
                             "port" => port,
                             "log.dir" => "#{tmp_dir}/kafka-logs_#{id}",
                             "kafka.csv.metrics.dir" => "#{tmp_dir}/kafka_metrics",
                             "num.partitions" => partition_count,
                             "zookeeper.connect" => "localhost:#{zk_port}"
                           ))
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

    def without_process
      @jr.without_process { yield }
    end
  end
end
