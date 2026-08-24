# frozen_string_literal: true

require_relative 'spec_helper'

RSpec::describe IS::ModuleReset do

  it 'simple dump' do
    ModA::ClsB.cls_inst_prop = :alpha
    state = IS::ModuleReset::dump(ModA)
    ModA.mod_cls_prop = :ooo
    ModA::ClsB.cls_inst_prop = :beta
    IS::ModuleReset::undump(state)
    expect(ModA.mod_cls_prop).to eq(100)
    expect(ModA::ClsB.cls_inst_prop).to eq(:alpha)
  end

  it 'isolate' do
    ModA::ClsB.cls_inst_prop = :alpha
    state = IS::ModuleReset::dump(ModA)
    IS::ModuleReset::isolate ModA do
      ModA.mod_cls_prop = :ooo
      ModA::ClsB.cls_inst_prop = :beta
    end
    expect(ModA.mod_cls_prop).to eq(100)
    expect(ModA::ClsB.cls_inst_prop).to eq(:alpha)
  end

end
