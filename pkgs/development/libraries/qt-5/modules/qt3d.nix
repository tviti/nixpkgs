{ qtModule, qtdeclarative }:

qtModule {
  name = "qt3d";
  qtInputs = [ qtdeclarative ];
  outputs = [ "out" "dev" ];
}
