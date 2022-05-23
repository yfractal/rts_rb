module RtsRB
  class Analyzor
    class TreeNode
      attr_reader :childreen, :name, :parent_count, :affected_specs

      def initialize(name, type='spec')
        @name = name
        @childreen = []
        @parent_count = 0
        @type = 'spec' # spec|file|method
        @affected_specs = []
      end

      def <<(child)
        @childreen << child
      end

      def childreen_count
        @childreen.count
      end

      def inc_parent_count
        @parent_count += 1
      end

      def add_affected_specs(spec)
        @affected_specs << spec
      end
    end

    attr_reader :file_to_node

    # Usage:
    # require 'analysis'
    # analysis = Analysis.new(file)
    # analysis.load
    # analysis.file_level
    def initialize(execuation_file)
      @execuation_file = execuation_file
    end

    def load
      @loaded = Crystalball::MapStorage::YAMLStorage.load(Pathname.new(@execuation_file))
    end

    def affected_specs(*files)
      files.map { |file| @file_to_node[file]}.compact.map do |node|
        percentage = node.parent_count / @file_to_node.keys.count.to_f * 100
        [node.name, node.parent_count, "#{percentage}%"]
      end
        .sort_by { |_, count, _| - count }
    end

    def file_level
      example_group = @loaded.example_groups
      @file_to_node = {}
      @specs = []
      example_group.each do |spec, affected_methods|
        spec_node = TreeNode.new(spec)
        @specs << spec_node

        affected_methods.each do |file, _|
          node = @file_to_node[file] || TreeNode.new(file, 'file')
          @file_to_node[file] = node

          spec_node << node
        end
      end

      @specs.each do |spec_node|
        spec_node.childreen.each do |child|
          child.inc_parent_count
          child.add_affected_specs(spec_node.name)
        end
      end

    end
  end
end
