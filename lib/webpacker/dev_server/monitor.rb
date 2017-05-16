class Webpacker::DevServer::Monitor
  delegate :pid_file_path, to: Webpacker::DevServer

  attr_reader :current_pid, :monitor_pid

  def initialize
    @exit_callbacks = []
    @current_pid = Process.pid

    at_exit do
      dead! if Process.pid == current_pid
    end
  end

  def on_exit(&block)
    @exit_callbacks << block
  end

  def start
    return if @started
    @started = true
    start_process_monitor
  end

  def stop
    return unless @started
    @started = false
    stop_process_monitor
  end

  private
    def start_process_monitor
      @monitor_pid = fork do
        loop do
          if alive?
            sleep 1
          else
            dead!
            break
          end
        end
      end
    end

    def stop_process_monitor
      Process.kill("HUP", monitor_pid) rescue nil
    end

    def alive?
      process_alive?(current_pid) && process_alive?(pid)
    end

    def pid
      pid_file_path.read.to_i if pid_file_path.exist?
    end

    def dead!
      run_exit_callbacks if @started
      stop
    end

    def process_alive?(pid)
      return false if pid.blank?
      Process.getpgid(pid)
      true
    rescue Errno::ESRCH
      false
    end

    def run_exit_callbacks
      @exit_callbacks.each(&:call)
    end
end
