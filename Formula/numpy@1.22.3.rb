class NumpyAT1223 < Formula
  desc "Package for scientific computing with Python"
  homepage "https://www.numpy.org/"
  url "https://files.pythonhosted.org/packages/64/4a/b008d1f8a7b9f5206ecf70a53f84e654707e7616a771d84c05151a4713e9/numpy-1.22.3.zip"
  sha256 "dbc7601a3b7472d559dc7b933b18b4b66f9aa7452c120e87dfb33d02008c8a18"
  license "BSD-3-Clause"
  head "https://github.com/numpy/numpy.git", branch: "main"

  # depends_on "./cython@0.29.28" => :build
  depends_on "gcc" => :build # for gfortran
  depends_on "openblas"
  depends_on "./python@3.10.2"

  fails_with gcc: "5"

  def install
    openblas = Formula["openblas"].opt_prefix
    ENV["ATLAS"] = "None" # avoid linking against Accelerate.framework
    ENV["BLAS"] = ENV["LAPACK"] = "#{openblas}/lib/libopenblas.dylib"

    config = <<~EOS
      [openblas]
      libraries = openblas
      library_dirs = #{openblas}/lib
      include_dirs = #{openblas}/include
    EOS

    Pathname("site.cfg").write config
    py = Formula["./python@3.10.2"]
    version = Language::Python.major_minor_version py.opt_bin/"python3"
    # ENV.prepend_create_path "PYTHONPATH", Formula["./cython@0.29.28"].opt_libexec/"lib/python#{version}/site-packages:#{py.site_packages}"
    system py.opt_bin/"python3", "setup.py", "build",
        "--fcompiler=gfortran", "--parallel=#{ENV.make_jobs}"
    system py.opt_bin/"python3", *Language::Python.setup_install_args(prefix)
  end

  test do
    system Formula["./python@3.10.2"].opt_bin/"python3", "-c", <<~EOS
      import numpy as np
      t = np.ones((3,3), int)
      assert t.sum() == 9
      assert np.dot(t, t).sum() == 27
    EOS
  end
end
