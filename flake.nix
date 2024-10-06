{
  description = "A collection of flake templates that I use commonly";

  outputs =
    { self }:
    {
      templates = {
        go = {
          path = ./go;
          description = "A basic go application with docker container building";
        };
        go-pulumi = {
          path = ./go-pulumi;
          description = "A starter pulumi golang flake with baked in pre-commit";
        };
      };

      defaultTemplate = self.templates.go;
    };
}
