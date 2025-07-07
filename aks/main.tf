resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "Green-Hat-dns"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "greenhatpool"
    node_count = 2
    vm_size    = "Standard_D4as_v5"
  }

  network_profile {
    network_plugin = "azure"
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "helm_release" "harbor" {
  name             = "green-hat-harbor"
  repository       = "https://helm.goharbor.io"
  chart            = "harbor"
  namespace        = "harbor"
  create_namespace = true

  values = [file("${path.module}/values/harbor-values.yaml")]

  set {
    name  = "harborAdminPassword"
    value = var.harbor_admin_password
  }

  depends_on = [helm_release.nginx_ingress]
}
