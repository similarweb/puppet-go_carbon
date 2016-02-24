require 'spec_helper'
describe 'go_carbon' do
  context 'with defaults for all parameters' do
    it { should contain_class('go_carbon') }
  end
end
