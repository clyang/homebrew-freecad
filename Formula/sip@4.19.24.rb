class SipAT41924 < Formula
  desc "Tool to create Python bindings for C and C++ libraries"
  homepage "https://www.riverbankcomputing.com/software/sip/intro"
  url "https://www.riverbankcomputing.com/static/Downloads/sip/4.19.24/sip-4.19.24.tar.gz"
  sha256 "edcd3790bb01938191eef0f6117de0bf56d1136626c0ddb678f3a558d62e41e5"
  license any_of: ["GPL-2.0-only", "GPL-3.0-only"]
  version "4.19.24"
  revision 1
  head "https://www.riverbankcomputing.com/hg/sip", using: :hg

  livecheck do
    url "https://riverbankcomputing.com/software/sip/download"
    regex(/href=.*?sip[._-]v?(\d+(\.\d+)+)\.t/i)
  end

  depends_on "freecad/freecad/python3.9"

  bottle do
    root_url "https://dl.bintray.com/vejmarie/freecad"
    cellar :any_skip_relocation
    sha256 "76e10ee255c7dda2f716ee4c2f3394d1fa7c1af7298f0ac58ff3863664e323bb" => :big_sur
    sha256 "c3b3dafcf16f0e65bea4ba6daf62d8e15394ee7201073008a7c7aa22c9864e81" => :catalina
  end
  
  keg_only "provided by homebrew core"

  def install
    ENV.prepend_path "PATH", Formula["freecad/freecad/python3.9"].opt_bin
    ENV.delete("SDKROOT") # Avoid picking up /Application/Xcode.app paths

    if build.head?
      # Link the Mercurial repository into the download directory so
      # build.py can use it to figure out a version number.
      ln_s cached_download/".hg", ".hg"
      # build.py doesn't run with python3
      system "python", "build.py", "prepare"
    end

    version = Language::Python.major_minor_version "python3"
    system "python3", "configure.py",
                      "--deployment-target=#{MacOS.version}",
                      "--destdir=#{lib}/python#{version}/site-packages",
                      "--bindir=#{bin}",
                      "--incdir=#{include}",
                      "--sipdir=#{HOMEBREW_PREFIX}/share/sip",
                      "--sip-module", "PyQt5.sip"
    system "make"
    system "make", "install"
  end

  def post_install
    (HOMEBREW_PREFIX/"share/sip").mkpath
  end

  test do
    (testpath/"test.h").write <<~EOS
      #pragma once
      class Test {
      public:
        Test();
        void test();
      };
    EOS
    (testpath/"test.cpp").write <<~EOS
      #include "test.h"
      #include <iostream>
      Test::Test() {}
      void Test::test()
      {
        std::cout << "Hello World!" << std::endl;
      }
    EOS
    (testpath/"test.sip").write <<~EOS
      %Module test
      class Test {
      %TypeHeaderCode
      #include "test.h"
      %End
      public:
        Test();
        void test();
      };
    EOS

    system ENV.cxx, "-shared", "-Wl,-install_name,#{testpath}/libtest.dylib",
                    "-o", "libtest.dylib", "test.cpp"
    system bin/"sip", "-b", "test.build", "-c", ".", "test.sip"
  end
end
