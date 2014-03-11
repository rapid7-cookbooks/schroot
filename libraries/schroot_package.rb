#
# Author:: Ryan Hass (<ryan_hass@rapid7.com>)
# Cookbook Name:: schroot
# Library:: package
#
# Copyright:: Copyright 2014, Rapid7, LLC.
#
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


require 'chef/mixin/command'
require 'chef/resource/package'
require 'chef/provider/package/apt'
require 'chef/mixin/shell_out'

class Chef
  class Resource
    class Package

      # Extend the Package resource to allow us to specify the schroot and user
      def schroot(arg=nil)
        set_or_return(
          :schroot,
          arg,
          :kind_of => [ String ]
        )
      end

      def user(arg=nil)
        set_or_return(
          :user,
          arg,
          :kind_of => [ String ]
        )
      end

      def default_release(arg=nil)
        set_or_return(
          :default_release,
          arg,
          :kind_of => [ String ]
        )
      end

      class AptPackage
        class Schroot < Chef::Resource::Package::AptPackage

          def initialize(name, run_context=nil)
            super
            #@current_resource = Chef::Resource::Package.new(@new_resource.name)
            @resource_name = :schroot_package
            @provider = Chef::Provider::Package::Apt::Schroot
            @user = 'root'
            @schroot = nil
          end

        end
      end
    end
  end

  class Provider
    class Package
      class Apt
        class Schroot < Chef::Provider::Package::Apt

          def load_current_resource
            super
            @current_resource = Chef::Resource::Package.new(@new_resource.name)
            @current_resource.user(@new_resource.user)
            @current_resource.schroot(@new_resource.schroot)
          end

          def shell_out(*command_args)
            # command_args is an array in which the first element is a string
            # containing the command to be executed, and the subsequent element
            # is a hash containing options to be handled by mixlib-shellout. We
            # convert the whole array to a string and back into an array of
            # elements to append the value of command_args as individual elements.
            schroot_args = ['schroot', '-c', new_resource.schroot, '-u', new_resource.user, '--', command_args[0]].join(' ')
            schroot_cmd = [ schroot_args ]
            cmd = Mixlib::ShellOut.new(*run_command_compatible_options(schroot_cmd))
            if STDOUT.tty? && !Chef::Config[:daemon] && Chef::Log.debug?
              cmd.live_stream = STDOUT
            end
            cmd.run_command
            cmd
          end

        end
      end
    end
  end
end

