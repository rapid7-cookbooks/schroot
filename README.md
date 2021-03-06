schroot cookbook
================
The schroot cookbook is used to create chroot environments which
can be used by non-root users. The creation of the environments
does require root access. Additionally, this cookbook allows one
to create environments of old vulnerable operating systems for
various purposes without having to expose them to your
infrastructure as a directly accessible/addressable asset.

Requirements
------------

Requires Chef 11 for `use_inline_resources` in LWRP.

### Platforms
- Debian, Ubuntu

### Cookbooks
- apt

# Usage
Put `depends 'schroot'` in your metadata.rb to gain access to the
schroot resource.


Resources/Providers
-------------------
### schroot

#### Example
``` ruby
# Create an Ubutu Hardy Chroot
schroot 'hardy_schroot' do
  path '/example/path'
  mirror 'http://old-releases.ubuntu.com/ubuntu'
  action :create
end
```

``` ruby
# Remove a chroot
schroot 'hardy_schroot' do
  path '/example/path'
  action :remove
end
```

#### Actions
- `:create` - This will create a schroot.conf file in /etc/schroot/chroot.d with all the configured parameters, and then run debootstrap to create the chroot.
- `:remove` - This will delete both the schroot config and the actual chroot.

#### Parameters
* `name` - Sets the name of the schroot in both config and the path.
* `description` - Optional description for the schroot.conf file.
* `path` - ** Required ** Defines the path to the chroot.
* `users` - An array of users allowed to use the chroot via schroot without root permissions.
* `groups` - An array of groups allowed to use the chroot via schroot without root permissions.
* `root_groups` - Array of system root groups in the chroot environment.
* `arch` - Architecture of the environment. Valid options are i386 and amd64. Default: amd64
* `dist` - Distribution/version of the OS to create. Eg: lucid
* `components` - Array of components to use when creating the chroot. Default: ['main', 'restricted', 'universe', 'multiverse']
* `mirror` - Mirror from which to retrieve packages. Default: 'http://mirror.anl.gov/ubuntu'

### schroot_execute

#### Example
``` ruby
# Execute command within a chroot
schroot_execute 'hardy_schroot' do
  command "mkdir /example_dir"
  user 'root'
  action :run
end
```

#### Actions
- `:run` - Execute the command
- `:nothing` - No-op, typically used when called by a notifies from another action.

#### Parameters
* `name` - The name of the schroot to use to execute the command.

The remander of the parameters mirror the Execute resource as this extends the
Execute resource to run within the schroot.

### package
This adds an additional provider to the standard `package` resource.

#### Actions
All the standard `package` actions apply.

See the Chef package resource documentation for details.

#### Example
``` ruby
# Install a package within a chroot
package 'build-essential' do
  provider Chef::Provider::Package::Apt::Schroot
  schroot 'hardy_schroot'
  user 'root'
  action :install
end
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

To-Do
-----
- Add support for schroot sessions
- Add support for unionfs and overlays
- Add chefspec to the cookbook
- Add support for btrfs

# Author

Author:: Ryan Hass (<ryan_hass@rapid7.com>)
