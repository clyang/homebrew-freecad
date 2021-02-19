class Freecad < Formula
  desc "Parametric 3D modeler"
  homepage "http://www.freecadweb.org"
  version "0.19pre"
  license "GPL-2.0-only"
  head "https://github.com/freecad/FreeCAD.git", branch: "master", shallow: false

  stable do
    # a tested commit that builds on macos high sierra 10.13, mojave 10.14, Catalina 10.15 & BigSur 11.0
    url "https://github.com/freecad/freecad.git",
      revision: "f35d30bc58cc2000754d4f30cf29d063416cfb9e"
    version "0.19pre-dev"
  end

  option "with-debug", "Enable debug build"
  option "with-macos-app", "Build MacOS App bundle"
  option "with-packaging-utils", "Optionally install packaging dependencies"
  option "with-cloud", "Build with CLOUD module"
  option "with-unsecured-cloud", "Build with self signed certificate support CLOUD module"
  option "with-skip-web", "Disable web"

  depends_on "ccache" => :build
  depends_on "cmake" => :build
  depends_on "swig" => :build
  depends_on "#@tap/boost@1.75.0"
  depends_on "#@tap/boost-python3@1.75.0"
  depends_on "#@tap/coin@4.0.0"
  depends_on "#@tap/matplotlib"
  depends_on "#@tap/med-file"
  depends_on "#@tap/nglib"
  depends_on "#@tap/opencamlib"
  depends_on "#@tap/pivy"
  depends_on "#@tap/pyside2"
  depends_on "#@tap/pyside2-tools"
  depends_on "#@tap/shiboken2"
  depends_on "freetype"
  depends_on macos: :high_sierra # no access to sierra test box
  depends_on "open-mpi"
  depends_on "openblas"
  depends_on "#@tap/opencascade@7.5.0"
  depends_on "orocos-kdl"
  depends_on "pkg-config"
  depends_on "#@tap/python3.9"
  depends_on "#@tap/qt5152"
  depends_on "#@tap/vtk@8.2.0"
  depends_on "webp"
  depends_on "xerces-c"

  bottle do
    root_url "https:/dl.bintray.com/vejmarie/freecad"
    sha256 "f9bc13c49a0ab3d72437dd721aa362d77638b68ad05f2bdcaeadf91b6d5e537b" => :big_sur
    sha256 "8ef75eb7cea8ca34dc4037207fb213332b9ed27976106fd83c31de1433c2dd29" => :catalina
  end

  def install
    system "pip3", "install", "six" unless File.exist?("#{HOMEBREW_PREFIX}/lib/python3.9/site-packages/six.py")

    # NOTE: brew clang compilers req, Xcode nowork on macOS 10.13 or 10.14
    if MacOS.version <= :mojave
      ENV["CC"] = Formula["llvm"].opt_bin/"clang"
      ENV["CXX"] = Formula["llvm"].opt_bin/"clang++"
    end

    # Disable function which are not available for Apple Silicon
    act = Hardware::CPU.arm? ? 'OFF' : 'ON'
    web = build.with?("skip-web") ? 'OFF' : act
    
    std_cmake_args = std_cmake_args.map{ |v| v == '-DCMAKE_BUILD_TYPE=Release' ? '-DCMAKE_BUILD_TYPE=Debug' : v }
    
    args = std_cmake_args + %W[
      -DBUILD_QT5=ON
      -DUSE_PYTHON3=1
      -DPYTHON_EXECUTABLE=#{HOMEBREW_PREFIX}/opt/python3.9/bin/python3
      -std=c++14
      -DCMAKE_CXX_STANDARD=14
      -DBUILD_ENABLE_CXX_STD:STRING=C++14
      -DBUILD_FEM_NETGEN=ON
      -DBUILD_FEM=ON
      -DBUILD_FEM_NETGEN:BOOL=ON
      -DBUILD_WEB=#{web}
      -DBUILD_PATH=ON
      -DFREECAD_USE_EXTERNAL_KDL=ON
    ]

    args << '-DCMAKE_PREFIX_PATH="' + Formula["#@tap/qt5152"].opt_prefix + "/lib/cmake;" + Formula["#@tap/nglib"].opt_prefix + "/Contents/Resources;" + Formula["#@tap/vtk@8.2.0"].opt_prefix + "/lib/cmake;" + Formula["#@tap/opencascade@7.5.0"].opt_prefix + "/lib/cmake;"+ Formula["#@tap/med-file"].opt_prefix + "/share/cmake/;" + Formula["#@tap/shiboken2"].opt_prefix + "/lib/cmake;" + Formula["#@tap/pyside2"].opt_prefix+ "/lib/cmake;" + Formula["#@tap/coin@4.0.0"].opt_prefix+ "/lib/cmake;" + Formula["#@tap/boost@1.75.0"].opt_prefix+ "/lib/cmake;" + Formula["#@tap/boost-python3@1.75.0"].opt_prefix+ '/lib/cmake;"'

    args << "-DFREECAD_CREATE_MAC_APP=1" if build.with? "macos-app"
    args << "-DBUILD_CLOUD=1" if build.with? "cloud"
    args << "-DALLOW_SELF_SIGNED_CERTIFICATE=1" if build.with? "unsecured-cloud"

    system "node", "install", "-g", "app_dmg" if build.with? "packaging-utils"
    
    if build.with? "macos-app"
      inreplace 'src/MacAppBundle/CMakeLists.txt', '${WEBKIT_FRAMEWORK_DIR}', "#{HOMEBREW_PREFIX}/opt/llvm/lib/ #{HOMEBREW_PREFIX}/opt/nglib/Contents/MacOS/ ${WEBKIT_FRAMEWORK_DIR}"
    end

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
    end

  end

  def post_install
    
    # dependency, is this the homebrew way?
    system "pip3", "install", "six" unless File.exist?("#{HOMEBREW_PREFIX}/lib/python3.9/site-packages/six.py")
    
    # There are three different situations, install with oder without FREECAD_CREATE_MAC_APP=1 or get the bottle
    bin.install_symlink "#{prefix}/FreeCAD.app/Contents/MacOS/FreeCAD" => "FreeCAD"
    bin.install_symlink "#{prefix}/FreeCAD.app/Contents/FreeCADCmd" => "FreeCADCmd"
    
    # What's the point of this file?
    if !File.exist?("#{prefix}/lib/python3.9/site-packages/homebrew-freecad-bundle.pth")
      (lib/"python3.9/site-packages/homebrew-freecad-bundle.pth").write "#{prefix}/FreeCAD.app/Contents/MacOS/\n"
    end
  end

  def caveats
    <<-EOS
    After installing FreeCAD you may want to do the following:

    1. Amend your PYTHONPATH environmental variable to point to
       the FreeCAD directory
         export PYTHONPATH=#{bin}:$PYTHONPATH
    EOS
  end
end
