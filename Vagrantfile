Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"
  config.vm.synced_folder ".", "/opt/stack/devstack-plugin-oidc/"

  # TODO(knikolla): I still have some unpushed changes to
  # https://github.com/CCI-MOC/sso. Have this clone after I have tested and
  # pushed.
  config.vm.synced_folder "../sso", "/opt/sso"

  # TODO(knikolla): I was having issues getting the ip address dynamically
  # during the provision step below. The command seemed to work correctly
  # during `vagrant ssh`, but not during the provision step. While I
  # investigate, leave hardcoded.
  config.vm.network "private_network", ip: "10.0.3.2"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "4096"
    vb.cpus = "2"
  end

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    set -xe

    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install docker.io docker-compose -y

    sudo mkdir -p /opt/stack
    sudo chown vagrant:vagrant /opt/stack

    cd /opt/sso && sudo docker-compose up -d

    cd ~
    if [ ! -d "devstack" ] ; then
        git clone https://opendev.org/openstack/devstack.git
    fi
    cd devstack

    cp samples/local.conf .
    echo "
        HOST_IP=10.0.3.2
        ENABLED_SERVICES=key,mysql,rabbit
        enable_plugin devstack-plugin-oidc https://github.com/knikolla/devstack-plugin-oidc main
    " >> local.conf
    ./stack.sh

    python3 /opt/stack/devstack-plugin-oidc/tools/test_login.py
  SHELL
end
