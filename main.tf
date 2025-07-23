
resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroupFreeTrial"
  location = "East US"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "publicip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "myNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "myLinuxVM"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  admin_password        = "admin@221309" # 🔐 Replace with a strong, secure password
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}



resource "null_resource" "install_nginx" {
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo apt install systemd",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]

    connection {
      type        = "ssh"
      host        = "172.171.203.231"            # Replace with your existing VM public IP
      user        = "azureuser"           # Your VM username
      password    = "admin@221309"    # Or use private_key if using SSH keys
      # private_key = file("~/.ssh/id_rsa")
      timeout     = "2m"
    }
  }

  # Optional: to force re-run, add a trigger, e.g., timestamp or external change
  triggers = {
    always_run = timestamp()
  }
}



resource "null_resource" "deploy_web_app" {
  provisioner "file" {
    source      = "C:/Users/Lenovo/Downloads/StreamFlix-build/StreamFlix-build"
    destination = "/tmp/StreamFlix-build"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /var/www/html/*",
      "sudo cp -r /tmp/StreamFlix-build/* /var/www/html/",
      "sudo chown -R www-data:www-data /var/www/html",
      "sudo systemctl restart nginx"
    ]
  }

  connection {
    type     = "ssh"
    user     = "azureuser"
    password = "admin@221309"  # Not recommended for production
    host     = "172.171.203.231"  # Replace with actual IP
  }

  triggers = {
    always_run = timestamp()
  }
}
