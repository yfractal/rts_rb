module RtsRB
  class ExecutionDetector
    attr_reader :root_path

    def initialize(root_path = Dir.pwd)
      @root_path = root_path
    end

    def detect(before)
      before = before_filter(before)

      result = {}
      before.each do |file, method_map|
        methods_map = method_map[:methods] # methods_map: { method => count }
        methods = []
        methods_map.each do |method, count|
          if count > 0
            methods << [method[0].to_s] + method[1..-1]
          end
        end

        if methods.count != 0
          result[file] = methods
        end
      end

      result
    end

    def before_filter(map)
      new_map = {}
      map.each do |file_name, val|
        if file_name.start_with?(root_path) && !file_name.end_with?('spec.rb')
          new_map[file_name.sub("#{root_path}/", '')] = val
        end
      end

      new_map
    end

    def after_filter(map)
      new_map = {}
      map.each do |file_name, val|
        new_map[file_name.sub("#{root_path}/", '')] = val.map { |v| [v[0].to_s] + v[1..-1]}
      end

      new_map
    end
  end
end
