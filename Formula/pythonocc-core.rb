class PythonoccCore < Formula
  desc "Pythonocc provides 3D modeling and dataexchange features. It is intended to CAD/PDM/PLM and BIM related development."
  homepage "https://www.pythonocc.org"
  url "https://github.com/tpaviot/pythonocc-core.git", :using => :git
  version "7.5.0"

  depends_on "#@tap/opencascade@7.5.0" => :required
  depends_on "cmake" => :build
  depends_on "#@tap/python3.9"

  def install
    mkdir "Build" do
     system "cmake", '-DOCE_LIB_PATH"' + Formula["#@tap/opencascade@7.5.0"].lib, '-DOCE_INCLUDE_PATH=' + Formula["#@tap/opencascade@7.5.0"].include + '/opencascade', *std_cmake_args , ".."
     system "make", "-j#{ENV.make_jobs}"
     system "make", "install"
    end
  end
  
  
end
