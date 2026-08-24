# frozen_string_literal: true

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
      # TODO: implement
    end

    private

    def dump_module state, mod
      # TODO: implement
    end

  end

end
