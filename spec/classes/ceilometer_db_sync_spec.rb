require 'spec_helper'

describe 'ceilometer::db::sync' do

  shared_examples_for 'ceilometer-upgrade' do

    it { is_expected.to contain_class('ceilometer::deps') }

    it 'runs ceilometer-upgrade' do
      is_expected.to contain_exec('ceilometer-upgrade').with(
        :command     => 'ceilometer-upgrade ',
        :path        => '/usr/bin',
        :refreshonly => 'true',
        :user        => 'ceilometer',
        :try_sleep   => 5,
        :tries       => 10,
        :timeout     => 300,
        :logoutput   => 'on_failure',
        :subscribe   => ['Anchor[ceilometer::install::end]',
                         'Anchor[ceilometer::config::end]',
                         'Anchor[ceilometer::dbsync::begin]'],
        :notify      => 'Anchor[ceilometer::dbsync::end]',
        :tag         => 'openstack-db',
      )
    end

    describe 'overriding params' do
      let :params do
        {
          :extra_params                => '--config-file=/etc/ceilometer/ceilometer_01.conf',
          :skip_gnocchi_resource_types => true,
          :db_sync_timeout             => 750,
        }
      end

      it { is_expected.to contain_exec('ceilometer-upgrade').with(
        :command     => 'ceilometer-upgrade --skip-gnocchi-resource-types --config-file=/etc/ceilometer/ceilometer_01.conf',
        :path        => '/usr/bin',
        :user        => 'ceilometer',
        :refreshonly => 'true',
        :try_sleep   => 5,
        :tries       => 10,
        :timeout     => 750,
        :logoutput   => 'on_failure',
        :subscribe   => ['Anchor[ceilometer::install::end]',
                         'Anchor[ceilometer::config::end]',
                         'Anchor[ceilometer::dbsync::begin]'],
        :notify      => 'Anchor[ceilometer::dbsync::end]',
        :tag         => 'openstack-db',
      )
      }
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts())
      end

      it_behaves_like 'ceilometer-upgrade'
    end
  end

end
