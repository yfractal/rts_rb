module RtsRB
  class StrategyTracePoint < Crystalball::MapGenerator::CoverageStrategy
    def initialize(execution_detector = ExecutionDetector.new)
      super(execution_detector)
      @current_traces = {}
      @dir = Dir.pwd
      @trace = TracePoint.new(:call) do |tracepoint|
        if tracepoint.path.start_with?(@dir)
          path = tracepoint.path.gsub(@dir, "")
          @current_traces[path] ||= []
          @current_traces[path] <<  [tracepoint.defined_class.to_s, tracepoint.method_id, tracepoint.lineno]
        end
      end
    end

    def after_register
      @trace.enable
    end

    def call(example_map, example)
      @current_traces = {}
      yield example_map, example
      example_map.push(*@current_traces)
    end
  end
end
