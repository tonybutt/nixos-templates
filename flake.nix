{
  description = "A collection of flake templates that I use commonly";
  
  outputs = {self}: {
    templates = {
      go = {
        path = ./go;
        description = "A basic go application with docker container building";
      };      
    };

    defaultTemplate = self.templates.go;
  };
}