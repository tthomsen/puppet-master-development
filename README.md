# puppet-master-development
This will create a vagrant environment for coding and testing your puppet modules.  When you run vagrant up you will get a Puppet Master servers running PE 3.3 and a single agent.

Before preforming your vagrant up, add ssh key to your to your git repository.

Bring up the environments.
```
vagrant up
```

After vagrant has run there are a few manual steps that need to be done on the Puppet Master.  SSH into the master.

```
vagrant ssh master
```

All of your module development will be done in module_workspace.  So we are going to need to make sure that the Puppet Master is aware of your module.
```
cd /etc/puppetmaster/puppet/
```

Add /etc/puppetlabs/puppet/module_workspace/ to basemodulepath.
```
vim puppet.conf
basemodulepath = /etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules:/etc/puppetlabs/puppet/module_workspace/
```

Restart Puppet for the changes to take effect.
```
service pe-httpd restart
```

Any dependent modules can be pull down into /etc/puppetlabs/puppet/modules from the forge.
