class MedFileAT410 < Formula
  desc "Modeling and Data Exchange standardized format library"
  homepage "https://www.salome-platform.org/"
  url "https://files.salome-platform.org/Salome/other/med-4.1.0.tar.gz"
  sha256 "847db5d6fbc9ce6924cb4aea86362812c9a5ef6b9684377e4dd6879627651fce"

  #bottle do
  #  root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
  #  sha256 cellar: :any, big_sur:   "21dc7b948d4bf3e022690bd075ed9f6e623c7d08088178f60a4f9f9acc70367c"
  #  sha256 cellar: :any, catalina:  "d66199bb1cbd71baf8f17bbef258fe64f02fe6f7cfc21427555f3c5b31297e1d"
  #  sha256 cellar: :any, mojave:    "112c796b6ae386478ee283bada3ce569d79638cd23abad655ca5f9c9d217b970"
  #end

  depends_on "cmake" => :build
  depends_on "./swig@4.0.2" => :build
  depends_on "gcc" => :build   # for gfortan
  depends_on "./python@3.9.7"
  depends_on "hdf5@1.10"

  def install
    python_prefix=`#{Formula["./python@3.9.7"].opt_bin}/python3-config --prefix`.chomp
    python_include=Dir["#{python_prefix}/include/*"].first

    # ENV.cxx11
    system "cmake", ".", "-DMEDFILE_BUILD_PYTHON=ON",
                         "-DMEDFILE_BUILD_TESTS=OFF",
                         "-DMEDFILE_INSTALL_DOC=OFF",
                         "-DPYTHON_INCLUDE_DIR=#{python_include}",
                         *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <med.h>
      #include <stdio.h>
      int main() {
        printf("%d.%d.%d",MED_MAJOR_NUM,MED_MINOR_NUM,MED_RELEASE_NUM);
        return 0;
      }
    EOS
    # NOTE: hdf5@1.10 is keg-only, `-I#{Formula["hdf5@1.10].include` no good.
    system ENV.cc, "-I#{include}", "-I/usr/local/opt/hdf5@1.10/include", "-L#{lib}", "-lmedC", "test.c"
    assert_equal version.to_s, shell_output("./a.out").chomp
  end
end
