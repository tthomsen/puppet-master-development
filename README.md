# puppet-master-development
A vagrant environment for coding and testing your puppet modules.

Add ssh key to your to your git repository.

```
vagrant up
```

Add /etc/puppetlabs/puppet/module_workspace/.
```
vagrant ssh master
cd /etc/puppetmaster/puppet/
vim puppet.conf
basemodulepath = /etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules:/etc/puppetlabs/puppet/module_workspace/
```
