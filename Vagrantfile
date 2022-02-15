Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2004"
  config.vm.synced_folder ".", "/opt/stack/devstack-plugin-oidc/"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "3072"
    vb.cpus = "2"
  end

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    set -xe

    sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install docker.io docker-compose -y

    # Used to detect the HOST_IP using `tools/config.sh`
    sudo apt-get install net-tools -y

    source /opt/stack/devstack-plugin-oidc/tools/config.sh

    sudo mkdir -p /opt/stack
    sudo chown vagrant:vagrant /opt/stack

    # Starts a Keycloak instance using `tools/docker-compose.yaml`
    cd /opt/stack/devstack-plugin-oidc/tools && sudo docker-compose up -d

    cd ~
    if [ ! -d "devstack" ] ; then
        git clone https://opendev.org/openstack/devstack.git
    fi
    cd devstack

    git checkout stable/wallaby

    cp samples/local.conf .
    echo "
        ENABLED_SERVICES=key,mysql,rabbit
        enable_plugin devstack-plugin-oidc https://github.com/knikolla/devstack-plugin-oidc main
    " >> local.conf
    ./stack.sh

    python3 /opt/stack/devstack-plugin-oidc/tools/test_login.py
  SHELL
end
