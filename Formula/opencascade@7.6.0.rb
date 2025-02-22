class OpencascadeAT760 < Formula
  desc "3D modeling and numerical simulation software for CAD/CAM/CAE"
  homepage "https://github.com/Open-Cascade-SAS"
  url "https://github.com/Open-Cascade-SAS/OCCT/archive/refs/tags/V7_6_0.tar.gz"

  version "7.6.0"
  sha256 "73f8f71be02c1d9a977e854bcc9202502184d339f1f212c19797a5f23baefabe"
  license "LGPL-2.1-only"
  # head "https://github.com/Open-Cascade-SAS/OCCT", branch: "master" # NOTE: not valid

  keg_only :versioned_formula # NOTE: homebrewcore provides opencascade too

  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "rapidjson" => :build
  depends_on "freeimage"
  depends_on "freetype"
  depends_on "./tbb@2020_u3"
  depends_on "tcl-tk"

  def install
    tcltk = Formula["tcl-tk"]
    system "cmake", ".",
                    "-DUSE_FREEIMAGE=ON",
                    "-DUSE_RAPIDJSON=ON",
                    "-DUSE_TBB=ON",
                    "-DINSTALL_DOC_Overview=ON",
                    "-D3RDPARTY_FREEIMAGE_DIR=#{Formula["freeimage"].opt_prefix}",
                    "-D3RDPARTY_FREETYPE_DIR=#{Formula["freetype"].opt_prefix}",
                    "-D3RDPARTY_RAPIDJSON_DIR=#{Formula["rapidjson"].opt_prefix}",
                    "-D3RDPARTY_RAPIDJSON_INCLUDE_DIR=#{Formula["rapidjson"].opt_include}",
                    "-D3RDPARTY_TBB_DIR=#{Formula["tbb@2020"].opt_prefix}",
                    "-D3RDPARTY_TCL_DIR:PATH=#{tcltk.opt_prefix}",
                    "-D3RDPARTY_TK_DIR:PATH=#{tcltk.opt_prefix}",
                    "-D3RDPARTY_TCL_INCLUDE_DIR:PATH=#{tcltk.opt_include}",
                    "-D3RDPARTY_TK_INCLUDE_DIR:PATH=#{tcltk.opt_include}",
                    "-D3RDPARTY_TCL_LIBRARY_DIR:PATH=#{tcltk.opt_lib}",
                    "-D3RDPARTY_TK_LIBRARY_DIR:PATH=#{tcltk.opt_lib}",
                    "-D3RDPARTY_TCL_LIBRARY:FILEPATH=#{tcltk.opt_lib}/libtcl#{tcltk.version.major_minor}.dylib",
                    "-D3RDPARTY_TK_LIBRARY:FILEPATH=#{tcltk.opt_lib}/libtk#{tcltk.version.major_minor}.dylib",
                    "-DCMAKE_INSTALL_RPATH:FILEPATH=#{lib}",
                    *std_cmake_args
    system "make", "install"

    bin.env_script_all_files(libexec/"bin", CASROOT: prefix)

    # Some apps expect resources in legacy ${CASROOT}/src directory
    prefix.install_symlink pkgshare/"resources" => "src"
  end

  test do
    # NOTE: the below test will fail on macos mojave due to recent bug
    # introducted from 7.5.{1,2,3} but not 7.5.0
    # v7.5.x errors when trying to exit
    # output = shell_output("#{bin}/DRAWEXE -c \"pload ALL\"")
    # assert_equal "1", output.chomp
    system "true"
  end
end
