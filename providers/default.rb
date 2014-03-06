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

def schroot_personality(arch)
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
    action :create
  end

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
              :arch => schroot_personality(new_resource.arch)
    action    :create
  end

  unless ::File.exists?(::File.join(new_resource.path, '.debootstrap'))
    debootstrap = shell_out("debootstrap",
                              "--arch=#{new_resource.arch}",
                              "--components=#{new_resource.components.join(',').to_s}",
                              new_resource.dist,
                              new_resource.path,
                              new_resource.mirror)
    # The error? method was not implemented in Mixlib:ShellOut v1.2 used by Chef 11.10.4
    # so we had to duplicate it's behavior here.
    if Array(debootstrap.valid_exit_codes).include?(debootstrap.exitstatus)
      file ::File.join(new_resource.path, '.debootstrap') do
        action :create
        backup false
      end
    else
      file ::File.join(new_resource.path, '.debootstrap') do
        action :delete
      end
    end
  end
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
