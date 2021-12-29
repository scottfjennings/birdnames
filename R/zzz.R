.onAttach <- function(libname, pkgname) {
  packageStartupMessage("If you have created and saved a local custom bird list
                        please read it into the Global Environment as custom_bird_list.
                        See Readme for details on creating custom bird list")
}
