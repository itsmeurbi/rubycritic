# frozen_string_literal: true

require 'analysers_test_helper'
require 'rubycritic/analysers/coverage'
require 'rubycritic/source_control_systems/base'
require 'fakefs/safe'

describe RubyCritic::Analyser::Coverage do
  describe '#run' do
    let(:coverage_path) do
      File.join(PathHelper.project_path, 'test', 'samples', 'coverage_sample')
    end

    before do
      @analysed_module = AnalysedModuleDouble.new(path: path)
      analysed_modules = [@analysed_module]
      analyser = RubyCritic::Analyser::Coverage.new(analysed_modules)
      analyser.run
    end

    around do |example|
      FakeFS do
        begin
          FakeFS::FileSystem.clone(PathHelper.project_path)
          FakeFS::FileSystem.clone(coverage_path, 'coverage')

          Dir.chdir(PathHelper.project_path)
          example.call
        ensure
          FakeFS::FileSystem.clear
        end
      end
    end

    context 'when analysing a file with no test coverage' do
      let(:path) { 'some_file.rb' }

      it 'calculates its test coverage as 0' do
        _(@analysed_module.coverage).must_equal 0
      end
    end

    context 'when analysing a file with some test coverage' do
      let(:path) { 'lib/rubycritic/source_control_systems/double.rb' }

      it 'calculates its test coverage' do
        _(@analysed_module.coverage).must_equal 75
      end
    end
  end
end
