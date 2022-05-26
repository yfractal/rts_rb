# coding: utf-8
module RtsRB
  class Analyzor
    class TreeNode
      attr_reader :childreen, :name, :parent_count, :affected_specs

      def initialize(name, type='spec')
        @name = name
        @childreen = []
        @parent_count = 0
        @type = type # spec|file|method
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

    attr_reader :file_to_node, :spec_to_node

    # Usage:
    # path = "#{Dir.pwd}/tmp/"
    # path = "#{Dir.pwd}/analysis/"
    # analyzor = RtsRB::Analyzor.new(path)
    # analyzor.load; analyzor.file_level
    def initialize(execuation_file)
      @execuation_file = execuation_file
    end

    def load
      @loaded = Crystalball::MapStorage::YAMLStorage.load(Pathname.new(@execuation_file))
    end

    def affected_specs(files)
      affected_specs_count = files.map { |file| @file_to_node[file]}.compact.map { |node| node.affected_specs }.flatten.uniq.count

      {
        affected_specs_count: affected_specs_count,
        percentage: affected_specs_count.to_f / @spec_to_node.count * 100
      }
    end

    def p90
      percentile(0.90)
    end

    def p95
      percentile(0.95)
    end

    def p99
      percentile(0.99)
    end

    def file_level
      example_group = @loaded.example_groups
      @file_to_node = {}
      @spec_to_node = {}

      example_group.each do |spec, affected_files|
        spec_node = TreeNode.new(spec)
        @spec_to_node[spec] = spec_node

        affected_files.each do |file|
          node = @file_to_node[file] || TreeNode.new(file, 'file')
          node.inc_parent_count
          node.add_affected_specs(spec_node.name)
          @file_to_node[file] = node

          spec_node << node
        end
      end
    end

    private
    def percentile(p)
      specs_count = @spec_to_node.count
      ordered = @file_to_node.map {|name, v| [name, v.affected_specs.count]}.sort_by {|x| x[1]}
      affect_tests_count = ordered[(ordered.count * p).round][1]
      affect_tests_count.to_f / specs_count * 100
    end
  end
end
