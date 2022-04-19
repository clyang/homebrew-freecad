class BoostPython3AT1780 < Formula
  desc "C++ library for C++/Python3 interoperability"
   homepage "https://www.boost.org/"
   url "https://boostorg.jfrog.io/artifactory/main/release/1.78.0/source/boost_1_78_0.tar.bz2"
   sha256 "8681f175d4bdb26c52222665793eef08490d7758529330f98d3b29dd0735bccc"
   license "BSL-1.0"
   head "https://github.com/boostorg/boost.git", branch: "master"

   livecheck do
      formula "./boost@1.7.8"
    end

  #  depends_on "./numpy@1.22.3" => :build
   depends_on "./boost@1.78.0"
   depends_on "./python@3.10.2"

   def install
     # "layout" should be synchronized with boost
     args = %W[
       -d2
       -j#{ENV.make_jobs}
       --layout=tagged-1.66
       --user-config=user-config.jam
       install
       threading=multi,single
       link=shared,static
     ]

     # Boost is using "clang++ -x c" to select C compiler which breaks C++14
     # handling using ENV.cxx14. Using "cxxflags" and "linkflags" still works.
     args << "cxxflags=-std=c++14"
     args << "cxxflags=-stdlib=libc++" << "linkflags=-stdlib=libc++" if ENV.compiler == :clang

     # disable python detection in bootstrap.sh; it guesses the wrong include
     # directory for Python 3 headers, so we configure python manually in
     # user-config.jam below.
     inreplace "bootstrap.sh", "using python", "#using python"

     pyver = Language::Python.major_minor_version Formula["./python@3.10.2"].opt_bin/"python3"
     py_prefix = Formula["./python@3.10.2"].opt_frameworks/"Python.framework/Versions/#{pyver}"
     py_prefix = Formula["./python@3.10.2"].opt_prefix if OS.linux?

     # Force boost to compile with the desired compiler
     compiler_text = if OS.mac?
       "using darwin : : #{ENV.cxx} ;"
     else
       "using gcc : : #{ENV.cxx} ;"
     end
     (buildpath/"user-config.jam").write <<~EOS
       #{compiler_text}
       using python : #{pyver}
                    : python3
                    : #{py_prefix}/include/python#{pyver}
                    : #{py_prefix}/lib ;
     EOS

     system "./bootstrap.sh", "--prefix=#{prefix}", "--libdir=#{lib}",
                              "--with-libraries=python", "--with-python=python3",
                              "--with-python-root=#{py_prefix}"

     system "./b2", "--build-dir=build-python3",
                    "--stagedir=stage-python3",
                    "--libdir=install-python3/lib",
                    "--prefix=install-python3",
                    "python=#{pyver}",
                    *args

     unless Dir.exist?(opt_prefix+'include')
       mkdir ('include')
       File.write('include/weneedit.txt', 'FreeCAD cmake need it.')
     end

     lib.install Dir["install-python3/lib/*.*"]
     (lib/"cmake").install Dir["install-python3/lib/cmake/boost_python*"]
    #  (lib/"cmake").install Dir["install-python3/lib/cmake/boost_numpy*"]
     doc.install Dir["libs/python/doc/*"]
   end

   test do
     (testpath/"hello.cpp").write <<~EOS
       #include <boost/python.hpp>
       char const* greet() {
         return "Hello, world!";
       }
       BOOST_PYTHON_MODULE(hello)
       {
         boost::python::def("greet", greet);
       }
     EOS

     pyincludes = shell_output("#{Formula["./python@3.10.2"].opt_bin}/python3-config --includes").chomp.split
     pylib = shell_output("#{Formula["./python@3.10.2"].opt_bin}/python3-config --ldflags --embed").chomp.split
     pyver = Language::Python.major_minor_version(Formula["./python@3.10.2"].opt_bin/"python3").to_s.delete(".")

     system ENV.cxx, "-shared", "-fPIC", "hello.cpp", "-L#{lib}", "-lboost_python#{pyver}", "-o",
            "hello.so", *pyincludes, *pylib

     output = <<~EOS
       import hello
       print(hello.greet())
     EOS
     assert_match "Hello, world!", pipe_output(Formula["./python@3.10.2"].opt_bin/"python3", output, 0)
   end
 end