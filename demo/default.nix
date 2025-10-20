{
  config = {
    units.first = {
      terranix = {
        terraform.backend.local.path = "/home/lillecarl/Code/terragrunix/first/unit.tfstate";
        # terraform.required_providers.local = {
        #   source = "opentffoundation/local";
        #   version = "2.5.3";
        # };
        # provider.local = { };
        locals.test1 = "testlocal";
        locals.test2 = "testlocal";
        locals.test3 = "asdf";
      };
    };
  };
}
