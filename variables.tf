variable "default_region" {
  type = string
}
variable "git_username" {
  type = string
}
variable "git_repo_url" {
  type = string
}
variable "db_name" {
  type = string  
}
variable "db_user" {
  type = string
}
variable "db_pwd" {
  type = string
  sensitive = true
}
variable "bucket_name" {
  type = string
}
variable "user_and_group" {
  type = string
}
variable "bucket_object_key" {
  type = string
}
variable "bucket_object_path" {
  type = string
}
#user input variables
variable "server_name" {
  type = string
}
variable "project_folder" {
  type = string
}
variable "nginx_conf_file" {
  type = string
}
variable "instance_name" {
  type = string
}
variable "key_pair_name" {
  type = string
}
variable "elastic_ip_tag_name" {
  type = string
}
variable "security_group_name"{
  type = string
}
variable "git_branch" {
  type = string
}
variable "mongodb_bucket_path" {
  type = string
}
variable "mongodb_db_dump_key" {
  type = string
}
variable "default_supervisor_conf_file" {
  type = string
}
variable "dropoff_supervisor_conf_file" {
  type = string
}
variable "mongodb_db_name" {
  type = string
}
