# kind_cluster.tf

provider "kind" {
}

provider "kubernetes" {
  config_path = pathexpand(var.kind_cluster_config_path)
}

provider "kubectl" {

    host = "${kind_cluster.default.endpoint}"
    cluster_ca_certificate = "${kind_cluster.default.cluster_ca_certificate}"
    client_certificate = "${kind_cluster.default.client_certificate}"
    client_key = "${kind_cluster.default.client_key}"

}


data "kubectl_file_documents" "namespace"{

    content = file("manifests/argocd/namespace.yaml")

}


data "kubectl_file_documents" "argocd"{

    content = file("manifests/argocd/install.yaml")

}


resource "kubectl_manifest" "namespace" {
    count     = length(data.kubectl_file_documents.namespace.documents)
    yaml_body = element(data.kubectl_file_documents.namespace.documents, count.index)
    override_namespace = "argocd"
}

resource "kubectl_manifest" "argocd" {
    depends_on = [
      kubectl_manifest.namespace,
    ]
    count     = length(data.kubectl_file_documents.argocd.documents)
    yaml_body = element(data.kubectl_file_documents.argocd.documents, count.index)
    override_namespace = "argocd"
}

data "kubectl_file_documents" "my-nginx-app" {
    content = file("manifests/argocd/my-nginx-app.yaml")
}

resource "kubectl_manifest" "my-nginx-app" {
    depends_on = [
      kubectl_manifest.argocd,
    ]
    count     = length(data.kubectl_file_documents.my-nginx-app.documents)
    yaml_body = element(data.kubectl_file_documents.my-nginx-app.documents, count.index)
    override_namespace = "argocd"
}


provider "helm" {

    kubernetes{

    host = "${kind_cluster.default.endpoint}"
    cluster_ca_certificate = "${kind_cluster.default.cluster_ca_certificate}"
    client_certificate = "${kind_cluster.default.client_certificate}"
    client_key = "${kind_cluster.default.client_key}"
    config_path = pathexpand(var.kind_cluster_config_path)   

    }

}


# resource "helm_release" "argocd" {
   
#       name = "argocd"
#       repository = "https://argoproj.github.io/argo-helm"
#       chart      = "argo-cd"
#       namespace  = "argocd"
#       version    = "4.9.7"
#       create_namespace = true

#       values = [
#         file("argocd/application.yaml")
#       ]

#       depends_on = [
#         kind_cluster.default
#       ]

# }




resource "kind_cluster" "default" {
  name            = var.kind_cluster_name
  kubeconfig_path = pathexpand(var.kind_cluster_config_path)
  wait_for_ready  = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      image = "kindest/node:v1.25.8"

      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]
      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }

      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }

    }

    node {
      role = "worker"
      
      image = "kindest/node:v1.25.8"
    }

    node {
      role = "worker"
      
      image = "kindest/node:v1.25.8"
    }


  }
}