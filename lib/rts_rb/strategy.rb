module RtsRB
  class Strategy < Crystalball::MapGenerator::CoverageStrategy
    def initialize(execution_detector = ExecutionDetector.new)
      super(execution_detector)
      @test_time = 0
      @coverge_time = 0
    end

    def after_register
      Coverage.start(methods: true)
    end

    def call(example_map, example)
      t_before_test = Time.now
      yield example_map, example
      t_after_test = Time.now
      after = Coverage.result(clear: true)
      rv = execution_detector.detect(after)
      t_after_detected = Time.now
      @test_time += t_after_test - t_before_test
      @coverge_time += t_after_detected - t_after_test
      example_map.push(*rv)
    end

    def total
      @test_time + @coverge_time
    end

    def detect_percentage
      @coverge_time / total.to_f * 100
    end
  end
end
