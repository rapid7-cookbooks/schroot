#
# Author:: Ryan Hass (<ryan_hass@rapid7.com>)
# Cookbook Name:: schroot
# Resource:: default
#
# Copyright 2014, Rapid7, LLC.
#

actions :create, :remove
default_action :create

attribute :name,        :kind_of => String,       :name_attribute => true
attribute :description, :kind_of => String,       :default => "schroot config created by Chef."
attribute :path,        :kind_of => String,       :required => true
attribute :users,       :kind_of => Array,        :default => ['schroot']
attribute :groups,      :kind_of => Array,        :default => ['schroot']
attribute :root_groups, :kind_of => Array,        :default => [ node['root_group'] ]
attribute :arch,        :kind_of => String,       :default => 'amd64'
attribute :os,          :kind_of => String,       :default => 'ubuntu'
attribute :dist,        :kind_of => String,       :default => 'hardy'
attribute :components,  :kind_of => Array,        :default => ['main', 'restricted', 'universe', 'multiverse']
attribute :mirror,      :kind_of => String,       :default => 'http://mirror.anl.gov/ubuntu'
