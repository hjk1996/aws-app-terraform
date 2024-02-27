output "open_search_vpc_endpoint_id" {
  value = aws_opensearchserverless_vpc_endpoint.vpc_endpoint.id
}

output "open_search_endpoint" {
  value = aws_opensearchserverless_collection.app_image_caption_vector_collection.collection_endpoint
}