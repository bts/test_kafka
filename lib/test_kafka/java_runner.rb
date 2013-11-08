require 'fileutils'
require 'socket' # daemon_controller needs it but currently doesn't require it
require 'daemon_controller'

module TestKafka
  class JavaRunner
    def initialize(id, tmp_dir, java_class, port, kafka_path, properties = {})
      @id = id
      @tmp_dir = tmp_dir
      @properties = properties
      @pid = nil
      @java_class = java_class
      @port = port
      @kafka_path = kafka_path
    end

    attr_reader :pid, :tmp_dir, :java_class, :kafka_path

    def start
      write_properties
      run
    end

    def stop
      daemon_controller.stop
    end

    def without_process
      stop
      begin
        yield
      ensure
        start
        sleep 5
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
      "exec java -Xmx512M -server -cp #{classpath} #{java_class} #{config_path}"
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
