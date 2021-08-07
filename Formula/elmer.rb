class Elmer < Formula
  desc "CFD"
  homepage "https://www.csc.fi/web/elmer"
  version "v10pre"
  license "GPL-2.0-only"
  head "https://github.com/ElmerCSC/elmerfem.git", branch: "devel", shallow: false

  stable do
    url "https://github.com/ElmerCSC/elmerfem.git",
      revision: "c40a03f2d0c77fa66afa7a476e8981fa8b7d74ac"
    version "v10pre"
  end
  
  option 'with-vtk9', 'Use the vtk9 toolkit.'
  
  @@vtk = build.with?('vtk9') ? './vtk@9.0.3' : './vtk@8.2.0' 

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/07.28.2021"
  end


  depends_on "cmake" => :build
  depends_on "./opencascade@7.5.0"
  depends_on "./python3.9"
  depends_on "./qt5152"
  depends_on "./qwtelmer"
  depends_on @@vtk
  depends_on "gcc"
  depends_on macos: :high_sierra # no access to sierra test box
  depends_on "open-mpi"
  depends_on "openblas"
  depends_on "webp"
  depends_on "xerces-c"

  def install
    args = std_cmake_args + %w[
      -DWITH_OpenMP:BOOLEAN=TRUE
      -DWITH_MPI:BOOLEAN=TRUE
      -DWITH_ELMERGUI:BOOLEAN=TRUE
      -DWITH_QT5:BOOLEAN=TRUE
    ]

    prefix_paths = ""
    { './qt5152'            => 'cmake',
      @@vtk                 => 'cmake',
      './opencascade@7.5.0' => 'cmake  -DCMAKE_C_FLAGS="-F',
      './qwtelmer'          => '/  -framework qwt"',
    }.each {|f,l| prefix_paths << Formula[f].lib/l  }
    args << "-DQWT_INCLUDE_DIR:STRING="+Formula["./qwtelmer"].lib/"qwt.framework/Versions/Current/Headers/"
    args << "-DQWT_LIBRARY:STRING="+Formula["./qwtelmer"].lib/"qwt.framework/Versions/Current/qwt"
    args << "-DCMAKE_PREFIX_PATH=\"#{prefix_paths}"
    
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
