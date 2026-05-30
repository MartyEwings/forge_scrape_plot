# frozen_string_literal: true

require 'spec_helper'

describe 'forge_scrape_plot::scrape' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_file('/var/log/forge_scrape').with_ensure('directory') }

      it 'installs the executable scrape script' do
        is_expected.to contain_file('/usr/local/bin/forge_plot.sh')
          .with_ensure('file')
          .with_mode('0755')
          .with_content(%r{forgeapi\.puppet\.com/v3/modules})
          .with_content(%r{"puppetlabs-influxdb"})
      end

      context 'with plot => false (default)' do
        it { is_expected.to contain_file('/etc/cron.d/forge_scrape_plot').with_ensure('absent') }
      end

      context 'with plot => true' do
        let(:params) { { 'plot' => true } }

        it 'installs the cron.d job' do
          is_expected.to contain_file('/etc/cron.d/forge_scrape_plot')
            .with_ensure('file')
            .with_content(%r{0 0 \* \* \* root /usr/local/bin/forge_plot\.sh})
        end
      end

      context 'with a custom module list and scrape_dir' do
        let(:params) do
          {
            'modules' => ['puppetlabs-stdlib'],
            'scrape_dir' => '/opt/forge',
          }
        end

        it { is_expected.to contain_file('/opt/forge').with_ensure('directory') }

        it 'renders the custom values into the script' do
          is_expected.to contain_file('/usr/local/bin/forge_plot.sh')
            .with_content(%r{scrape_dir="/opt/forge"})
            .with_content(%r{"puppetlabs-stdlib"})
        end
      end
    end
  end
end
