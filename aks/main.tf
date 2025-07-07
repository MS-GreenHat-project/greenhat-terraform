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

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  values = [file("${path.module}/values/argocd-values.yaml")]

  depends_on = [helm_release.nginx_ingress]
}

resource "helm_release" "harbor" {
  name             = "green-hat-harbor"
  repository       = "https://helm.goharbor.io"
  chart            = "harbor"
  namespace        = "harbor"
  create_namespace = true
  
  # Harbor 설치 시간이 오래 걸릴 수 있으므로 timeout 증가
  timeout = 600
  
  # 설치 실패 시 정리
  cleanup_on_fail = true
  
  # 원자적 설치 (실패 시 롤백)
  atomic = true

  values = [file("${path.module}/values/harbor-values.yaml")]

  set {
    name  = "harborAdminPassword"
    value = var.harbor_admin_password
  }
  
  # LoadBalancer IP가 할당될 때까지 대기
  set {
    name  = "expose.loadBalancer.sourceRanges"
    value = "{0.0.0.0/0}"
  }

  depends_on = [helm_release.argocd]
}
