#!/bin/bash

# Interactive prompt
echo "Do you want to install or uninstall k3s? (install/uninstall)"
read -r ACTION

if [ "$ACTION" == "uninstall" ]; then
    echo "🔄 Uninstalling k3s..."
    sudo /usr/local/bin/k3s-uninstall.sh
    echo "✅ k3s has been removed."

elif [ "$ACTION" == "install" ]; then
    echo "🚀 Installing k3s..."
    curl -sfL https://get.k3s.io | sh -

    echo "🔧 Fixing kubectl permissions..."
    mkdir -p $HOME/.kube
    sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
    sudo chown $USER:$USER $HOME/.kube/config

    echo "📦 Setting KUBECONFIG environment variable..."
    if ! grep -q "export KUBECONFIG=\$HOME/.kube/config" ~/.bashrc; then
        echo 'export KUBECONFIG=$HOME/.kube/config' >> ~/.bashrc
        source ~/.bashrc
    fi

    echo "✅ k3s installed and kubectl is ready to use without sudo."
else
    echo "❌ Invalid option. Please type 'install' or 'uninstall'."
fi