require 'spec_helper'

describe 'aodh::db' do

  shared_examples 'aodh::db' do

    context 'with default parameters' do
      it { is_expected.to contain_oslo__db('aodh_config').with(
        :db_max_retries => '<SERVICE DEFAULT>',
        :connection     => 'sqlite:////var/lib/aodh/aodh.sqlite',
        :idle_timeout   => '<SERVICE DEFAULT>',
        :min_pool_size  => '<SERVICE DEFAULT>',
        :max_pool_size  => '<SERVICE DEFAULT>',
        :max_retries    => '<SERVICE DEFAULT>',
        :retry_interval => '<SERVICE DEFAULT>',
        :max_overflow   => '<SERVICE DEFAULT>',
      )}

    end

    context 'with specific parameters' do
      let :params do
        { :database_db_max_retries => '-1',
          :database_connection     => 'mysql+pymysql://aodh:aodh@localhost/aodh',
          :database_idle_timeout   => '3601',
          :database_min_pool_size  => '2',
          :database_max_pool_size  => '11',
          :database_max_retries    => '11',
          :database_retry_interval => '11',
          :database_max_overflow   => '21',
        }
      end
      it { is_expected.to contain_oslo__db('aodh_config').with(
        :db_max_retries => '-1',
        :connection     => 'mysql+pymysql://aodh:aodh@localhost/aodh',
        :idle_timeout   => '3601',
        :min_pool_size  => '2',
        :max_pool_size  => '11',
        :max_retries    => '11',
        :retry_interval => '11',
        :max_overflow   => '21',
      )}

    end

    context 'with postgresql backend' do
      let :params do
        { :database_connection => 'postgresql://localhost:1234/aodh', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('python-psycopg2').with(:ensure => 'present')
      end

    end

    context 'with MySQL-python library as backend package' do
      let :params do
        { :database_connection => 'mysql://aodh:aodh@localhost/aodh', }
      end

      it { is_expected.to contain_package('python-mysqldb').with(:ensure => 'present') }
    end

    context 'with mongodb backend' do
      let :params do
        { :database_connection => 'mongodb://localhost:1234/aodh', }
      end

      it 'installs python-mongodb package' do
        is_expected.to contain_package('python-pymongo').with(
          :ensure => 'present',
          :name   => 'python-pymongo',
          :tag    => 'openstack'
        )
        is_expected.to contain_oslo__db('aodh_config').with(
          :connection => 'mongodb://localhost:1234/aodh',
        )
      end

    end

    context 'with incorrect database_connection string' do
      let :params do
        { :database_connection => 'redis://aodh:aodh@localhost/aodh', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end

    context 'with incorrect pymysql database_connection string' do
      let :params do
        { :database_connection => 'foo+pymysql://aodh:aodh@localhost/aodh', }
      end

      it_raises 'a Puppet::Error', /validate_re/
    end
  end

  shared_examples_for 'aodh::db on Debian' do
    context 'with sqlite backend' do
      let :params do
        { :database_connection => 'sqlite:///var/lib/aodh/aodh.sqlite', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('python-pysqlite2').with(
          :ensure => 'present',
          :name   => 'python-pysqlite2',
          :tag    => 'openstack'
        )
      end
    end

    context 'using pymysql driver' do
      let :params do
        { :database_connection => 'mysql+pymysql://aodh:aodh@localhost/aodh', }
      end

      it 'install the proper backend package' do
        is_expected.to contain_package('python-pymysql').with(
          :ensure => 'present',
          :name   => 'python-pymysql',
          :tag    => 'openstack'
        )
      end
    end
  end

  shared_examples_for 'aodh::db on RedHat' do
    context 'using pymysql driver' do
      let :params do
        { :database_connection => 'mysql+pymysql://aodh:aodh@localhost/aodh', }
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      case facts[:osfamily]
      when 'Debian'
        it_configures 'aodh::db on Debian'
      when 'RedHat'
        it_configures 'aodh::db on RedHat'
      end
      it_configures 'aodh::db'
    end
  end
end

