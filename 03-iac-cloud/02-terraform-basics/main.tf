module "basics" {
  source = "./modules/basics"

  student_name = var.student_name
}

module "basics2" {
  source = "./modules/basics"

  student_name = var.student_name_2
}
