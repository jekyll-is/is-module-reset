# frozen_string_literal: true

require 'is-deep'

require_relative 'info'

module IS::ModuleReset

  class << self

    def dump *mods
      state = {}
      mods.each do |mod|
        dump_module state, mod
      end
      state.deep_dup
    end

    def undump state
      state.each do |mod, mod_state|
        mod.class_variables.each { mod.remove_class_variable it }
        mod_state[:class_vars].each do |var, value|
          mod.class_variable_set var, value
        end
        mod.instance_variables.each { mod.remove_instance_variable it }
        mod_state[:instance_vars].each do |var, value|
          mod.instance_variable_set var, value
        end
      end
    end

    def isolate *mods
      raise 'Block is required!' unless block_given?
      state = dump(*mods)
      yield
      undump state
    end

    private

    def dump_module state, mod
      mod_state = { instance_vars: {}, class_vars: {} }
      mod.class_variables.each do |var|
        mod_state[:class_vars][var] = mod.class_variable_get(var)
      end
      mod.instance_variables.each do |var|
        mod_state[:instance_vars][var] = mod.instance_variable_get(var)
      end
      state[mod] = mod_state
      mod.constants(false).each do |const|
        value = mod.const_get(const)
        dump_module state, value if value.is_a?(Module)
      end
    end

  end

end
