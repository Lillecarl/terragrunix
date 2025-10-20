{
  config = {
    units.first = {
      terraform = {
        copy_terraform_lock_file = false;
      };
      terranix = {
        terraform.required_providers.local = {
          source = "opentffoundation/local";
          version = "2.5.3";
        };
        provider.local = { };
        locals.test = "testlocal";
      };
    };
  };
}
