terraform {
    cloud{
     organization = "terraform-altschool-exercises-project"

     workspaces {
        name = "terraform-project"
      }
   }
}