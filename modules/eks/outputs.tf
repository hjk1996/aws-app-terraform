output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}
