class Elmer < Formula
  desc "CFD"
  homepage "https://www.csc.fi/web/elmer"
  version "10pre"
  license "GPL-2.0-only"
  head "https://github.com/ElmerCSC/elmerfem.git", branch: "devel", shallow: false

  stable do
    url "https://github.com/ElmerCSC/elmerfem.git",
      revision: "c40a03f2d0c77fa66afa7a476e8981fa8b7d74ac"
    version "v10pre"
  end

  #bottle do
  #  root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
  #end

  depends_on "cmake" => :build
  depends_on "./opencascade@7.5.1"
  depends_on "./python@3.9.7"
  depends_on "./qt5152"
  depends_on "./qwtelmer"
  depends_on "./vtk@9.0.03"
  depends_on "gcc"
  depends_on macos: :high_sierra # no access to sierra test box
  depends_on "open-mpi"
  depends_on "openblas"
  depends_on "webp"
  depends_on "xerces-c"

  def install
    qwt_include_dir = Formula["#{@tap}/qwtelmer"].opt_prefix+"/lib/qwt.framework/Versions/Current/Headers/"
    qwt_library = Formula["#{@tap}/qwtelmer"].opt_prefix+"/lib/qwt.framework/Versions/Current/qwt"

    prefix_paths = ""
    prefix_paths << (Formula["#{@tap}/qt5152"].opt_prefix/"lib/cmake;")
    prefix_paths << (Formula["#{@tap}/vtk@9.0.3"].opt_prefix/"lib/cmake;")
    prefix_paths << (Formula["#{@tap}/opencascade@7.5.1"].opt_prefix/"lib/cmake;")

    cmake_cflags = ""
    cmake_cflags << ('" -F' + Formula["#{@tap}/qwtelmer"].opt_prefix+"/lib/" + ' -framework qwt"')

    args = std_cmake_args + %W[
      -DQWT_INCLUDE_DIR=#{qwt_include_dir}
      -DQWT_LIBRARY=#{qwt_library}
      -DCMAKE_C_FLAGS=#{cmake_cflags}
      -DWITH_OpenMP:BOOLEAN=TRUE
      -DWITH_MPI:BOOLEAN=TRUE
      -DWITH_ELMERGUI:BOOLEAN=TRUE
      -DWITH_QT5:BOOLEAN=TRUE
    ]

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end

  def post_install; end

  def caveats
    <<-EOS
    EOS
  end
end
