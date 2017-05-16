require "childprocess"

class Webpacker::DevServer::Process
  delegate :pid_file_path, :command_file_path, :log_file_path, to: Webpacker::DevServer

  def start
    process.start
    pid_file_path.write(process.pid)
  end

  def stop
    process.stop
    pid_file_path.unlink if pid_file_path.exist?
  end

  def alive?
    process.alive?
  end

  private
    def process
      @process ||= ChildProcess.build(command_file_path.to_s).tap do |process|
        process.leader = true
        process.detach = true
        process.io.stdout = process.io.stderr = log_file_path.open("w")
      end
    end
end
