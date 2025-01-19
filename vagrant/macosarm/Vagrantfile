Vagrant.configure("2") do |config|
  config.vm.box = "spox/ubuntu-arm"
  config.vm.box_version = "1.0.0"
  config.vm.network "private_network", ip: "192.168.56.11"
  config.vm.provider "vmware_desktop" do |vmware|
    vmware.gui = true
    vmware.memory = 2048
    vmware.allowlist_verified = true
    vmware.linked_clone = false
    vmware.vmx["ethernet0.virtualdev"] = "vmxnet3"
    vmware.ssh_info_public = true
  end 
end
