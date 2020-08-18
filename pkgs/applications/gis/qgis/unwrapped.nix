{ mkDerivation, lib, fetchFromGitHub, cmake, ninja, flex, bison, protobuf, proj, geos, xlibsWrapper, sqlite, gsl
, qwt, fcgi, python3Packages, libspatialindex, libspatialite, postgresql
, txt2tags, openssl, libzip, hdf5, netcdf, exiv2
, qtbase, qt3d, qtwebkit, qtsensors, qca-qt5, qtkeychain, qscintilla, qtserialport, qtxmlpatterns
, withGrass ? true, grass
}:
with lib;
let
  pythonBuildInputs = with python3Packages;
    [ qscintilla-qt5 gdal jinja2 numpy psycopg2
      chardet dateutil pyyaml pytz requests urllib3 pygments pyqt5 sip owslib six ];
in mkDerivation rec {
  version = "3.14.15";
  pname = "qgis";
  name = "${pname}-unwrapped-${version}";

  src = fetchFromGitHub {
    owner = "qgis";
    repo = "QGIS";
    rev = "final-${lib.replaceStrings ["."] ["_"] version}";
    sha256 = "03skj8dd5rqi5k22zi8bly1sbynywm2bv6184dhjvw4i2vv4p3rl";
  };

  passthru = {
    inherit pythonBuildInputs;
    inherit python3Packages;
  };

  buildInputs = [ openssl protobuf proj geos xlibsWrapper sqlite gsl qwt exiv2
    fcgi libspatialindex libspatialite postgresql txt2tags libzip hdf5 netcdf
    qtbase qtwebkit qtsensors qca-qt5 qtkeychain qscintilla qtserialport qtxmlpatterns qt3d ] ++
    (lib.optional withGrass grass) ++ pythonBuildInputs;

  nativeBuildInputs = [ cmake flex bison ninja ];

  # Force this pyqt_sip_dir variable to point to the sip dir in PyQt5
  #
  # TODO: Correct PyQt5 to provide the expected directory and fix
  # build to use PYQT5_SIP_DIR consistently.
  postPatch = ''
     substituteInPlace cmake/FindPyQt5.py \
       --replace 'sip_dir = cfg.default_sip_dir' 'sip_dir = "${python3Packages.pyqt5}/share/sip/PyQt5"'
   '';
  
  cmakeFlags = [ "-DCMAKE_SKIP_BUILD_RPATH=OFF"
                 "-DPYQT5_SIP_DIR=${python3Packages.pyqt5}/share/sip/PyQt5"
                 "-DQSCI_SIP_DIR=${python3Packages.qscintilla-qt5}/share/sip/PyQt5"
                 "-DWITH_3D=True"
               ] ++
                 lib.optional withGrass "-DGRASS_PREFIX7=${grass}/${grass.name}";

  meta = {
    description = "A Free and Open Source Geographic Information System";
    homepage = "http://www.qgis.org";
    license = lib.licenses.gpl2Plus;
    platforms = with lib.platforms; linux;
    maintainers = with lib.maintainers; [ lsix ];
  };
}
