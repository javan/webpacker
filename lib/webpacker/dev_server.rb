# Loads webpack-dev-server configuration from config/webpack/development.server.yml

require "webpacker/file_loader"

class Webpacker::DevServer < Webpacker::FileLoader
  autoload :Process, "webpacker/dev_server/process"
  autoload :Monitor, "webpacker/dev_server/monitor"
  autoload :RackAutoStart, "webpacker/dev_server/rack_auto_start"

  class << self
    def auto_start?
      config[:auto_start]
    end

    def start
      return if running?
      process.start
      monitor.start
    end

    def stop
      process.stop
      monitor.stop
    end

    def running?
      process.alive? || pid_file_path.exist? || port_in_use?
    end

    def monitor
      @monitor ||= Webpacker::DevServer::Monitor.new.tap do |monitor|
        monitor.on_exit { stop }
      end
    end

    def process
      @process ||= Webpacker::DevServer::Process.new
    end

    def port_in_use?
      socket = Socket.tcp(config[:host], config[:port], connect_timeout: 1)
      socket.close
      true
    rescue Errno::ECONNREFUSED
      false
    end

    def config
      load if Webpacker.env.development?
      raise Webpacker::FileLoader::FileLoaderError.new("Webpacker::DevServer.load must be called first") unless instance
      instance.data
    end

    def file_path
      Rails.root.join("config/webpack/development.server.yml")
    end

    def pid_file_path
      Rails.root.join("tmp/webpack-dev-server.pid")
    end

    def command_file_path
      Rails.root.join("bin/webpack-dev-server")
    end

    def log_file_path
      Rails.root.join("log/webpack-dev-server.log")
    end
  end

  private
    def load
      return super unless File.exist?(@path)
      HashWithIndifferentAccess.new(YAML.load(File.read(@path))[Webpacker.env])
    end
end
