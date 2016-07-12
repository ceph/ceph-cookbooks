Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |vb|
    vb.customize [ "storagectl", :id, "--name", "IDE Controller", "--remove" ]
    vb.customize [ "storagectl", :id, "--name", "OSD Controller", "--add", "scsi", "--bootable", "off" ]
  end
  (0..2).each do |d|
    config.vm.provider :virtualbox do |vb|
      vb.customize [ "createhd", "--filename", "disk-#{d}", "--size", "1000" ]
      vb.customize [ "storageattach", :id, "--storagectl", "OSD Controller", "--port", d, "--type", "hdd", "--medium", "disk-#{d}.vdi" ]
    end
  end
end
