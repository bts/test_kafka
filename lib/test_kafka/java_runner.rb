require 'fileutils'
require 'socket' # daemon_controller needs this but currently doesn't require it
require 'daemon_controller'

module TestKafka
  class JavaRunner
    MAX_HEAP_SIZE = 512

    def initialize(id, tmp_dir, java_class, port, kafka_path, properties={})
      @id = id
      @tmp_dir = tmp_dir
      @properties = properties
      @java_class = java_class
      @port = port
      @kafka_path = kafka_path
    end

    attr_reader :tmp_dir, :java_class, :kafka_path

    def start
      write_properties
      run
    end

    def stop
      daemon_controller.stop
    end

    def with_interruption
      stop
      begin
        yield
      ensure
        start
      end
    end

    private

    def classpath
      [
        "core/target/scala-*/*.jar",
        "perf/target/scala-*/kafka*.jar",
        "libs/*.jar",
        "kafka*.jar"
      ].flat_map { |pattern| Dir.glob(kafka_path + "/" + pattern) }.join(":")
    end

    def java_command
      "exec java -Xmx#{MAX_HEAP_SIZE}M -server -cp #{classpath} #{java_class} #{config_path}"
    end

    def daemon_controller
      @dc ||= DaemonController.new(
        :identifier => @id,
        :start_command => "#{java_command} >>#{log_path} 2>&1 & echo $! > #{pid_path}",
        :ping_command => [:tcp, '127.0.0.1', @port],
        :pid_file => pid_path,
        :log_file => log_path,
        :start_timeout => 25
      )
    end

    def run
      FileUtils.mkdir_p(log_dir)
      FileUtils.mkdir_p(pid_dir)
      daemon_controller.start
    end

    def write_properties
      FileUtils.mkdir_p(config_dir)
      File.open(config_path, "w+") do |f|
        @properties.each do |k,v|
          f.puts "#{k}=#{v}"
        end
      end
    end

    def pid_path
      "#{pid_dir}/#{@id}.pid"
    end

    def pid_dir
      "#{tmp_dir}/pid"
    end

    def log_path
      "#{log_dir}/#{@id}.log"
    end

    def log_dir
      "#{tmp_dir}/log"
    end

    def config_path
      "#{config_dir}/#{@id}.properties"
    end

    def config_dir
      "#{tmp_dir}/config"
    end
  end
end
