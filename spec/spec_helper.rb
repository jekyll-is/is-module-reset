# spec/spec_helper.rb

require "bundler/setup"
require 'simplecov'

# Запуск SimpleCov один раз в начале, перед загрузкой тестируемого кода
SimpleCov.start do
  # minimum_coverage 50  # минимальный процент покрытия
end

require_relative '../lib/is-module-reset'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

module ModA

  @@mod_cls_var = 100

  class << self

    def mod_cls_prop
      @@mod_cls_var
    end

    def mod_cls_prop= value
      @@mod_cls_var = value
    end

    def mod_cls_prop2
      @@mod_cls_var2
    end

    def mod_cls_prop2= value
      @@mod_cls_var2 = value
    end

    attr_accessor :mod_inst_prop

  end

  class ClsB

    class << self

      attr_accessor :cls_inst_prop

      def cls_cls_prop
        @@cls_cls_var
      end

      def cls_cls_prop= value
        @@cls_cls_var = value
      end

    end

  end

end
