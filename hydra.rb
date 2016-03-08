#/usr/bin/env ruby
require 'open3'
#require 'logger'
require 'optparse'
require 'thread'
#require 'ap'

options = {}
options[:nb_threads] = 1
op = OptionParser.new do |opts|
  opts.banner = "Usage: hydra.rb [options] 'list,of,hosts' 'commands ; to ; execute'"

  opts.on("-p 1", "--parallel 1", "Number of threads to be executed in parallel ; 0 means as much thread as we have hosts", Integer) do |i|
    options[:nb_threads] = i
  end
end

begin op.parse! ARGV
rescue OptionParser::ParseError => e
  puts e
  puts op
  exit 1
end

hosts=ARGV.shift.split(',')
commands = ARGV.empty? ? ARGF.read : ARGV.shift

class SshRequests
  SSHPATH='/usr/bin/ssh'
  BLOCK_SIZE = 1024
  attr_accessor :hosts, :commands, :results
  def initialize(h,c)
    @hosts,@commands = h,c
    @results = Hash.new()
  end

  def execute
    #TODO sanitize this
    cmd = "#{SSHPATH} #{@hosts} #{@commands}"
    puts cmd
    o, e, t =  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      #TODO : add option to skip if  doesn't work :-( would like to kill wait_thr if stdin is required
      #        Process.kill("HUP",wait_thr.pid)
      stdin.close
      #should flush time to time (cf. tail -F)
      captured_stdout = stdout.read
      captured_stderr = stderr.read
      puts captured_stdout
      puts wait_thr.value # Process::Status object returned.
      [captured_stdout, captured_stderr, wait_thr.value]
    end
    @results[@hosts.to_sym]={cmd: cmd, stdout: o, stderr: e, thread: t}
  end

  def execute2
    cmd = "#{SSHPATH} #{@hosts} #{@commands}"
    @results[@hosts.to_sym]={cmd: cmd, stdout: "", stderr: ""}
     Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      stdin.close_write
      begin
        files = [stdout, stderr]
        until files.empty? do # modified
          ready = IO.select(files)
          if ready
            readable = ready[0]

            readable.each do |f|
              fileno = f.fileno
              begin
                res = f.equal?(stdout) ? :stdout : :stdin
                data = f.read_nonblock(BLOCK_SIZE)

                puts "#{res}, data:\n#{data}"
                #@results[@hosts.to_sym][res] << data unless data.nil?
                @results[@hosts.to_sym][res]&.concat(data)
              rescue EOFError => e
                files.delete f # added
              end
            end
          end
        end
      end
      @results[@hosts.to_sym][:thread] = wait_thr.value
    end
  end
end

work_q = Queue.new
hosts.each{|x| work_q.push x }
nbthreads = options[:nb_threads]==0 ? hosts.size : options[:nb_threads]
workers = (0...nbthreads).map do
  Thread.new do
    begin
      while x = work_q.pop(true)
        #TODO: need a thread safe hash to store results
        xxx = SshRequests.new(x,commands)
        xxx.execute2
      end
    rescue ThreadError
    end
  end
end
workers.map(&:join)
