#
# Author:: Ryan Hass (<ryan_hass@rapid7.com>)
# Cookbook Name:: schroot
# Provider:: default
#
# Copyright 2014, Rapid7, LLC.
#

require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

use_inline_resources

def whyrun_supported?
  true
end

def personality(arch)
  case arch
  when 'amd64'
    @personality = 'linux'
  when 'i386'
    @personality = 'linux32'
  else
    Chef::Log.error("Unsupported platform #{arch} specified.")
  end
end

action :create do
  directory new_resource.path do
    recursive true
    action :nothing
  end

  Chef::Log.debug('Template attribute provided, all other attributes ignored.')

  template "/etc/schroot/chroot.d/#{new_resource.name}.conf" do
    source    'schroot.conf.erb'
    cookbook  'schroot'
    owner     'root'
    group     node['root_group']
    mode      0644
    variables :name => new_resource.name,
              :description => new_resource.description,
              :path => new_resource.path,
              :users => new_resource.users.join(',').to_s,
              :groups => new_resource.groups.join(',').to_s,
              :root_groups => new_resource.root_groups.join(',').to_s,
              :arch => personality(new_resource.arch)
    action    :create
  end

  #TODO: Make this idempotent, and possibly a seperate class.
  debootstrap = shell_out!("debootstrap", "--arch=#{new_resource.arch}", "--components=#{new_resource.components.join(',').to_s}", new_resource.dist, new_resource.path, new_resource.mirror)
end

action :remove do
  file "/etc/schroot/chroot.d/#{new_resource.name}.conf" do
    action :delete
  end

  directory new_resource.path do
    recursive true
    action :delete
  end
end
