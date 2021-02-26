class Smesh < Formula
  desc "A stand-alone library of the mesh framework from the Salome Platform."
  homepage "https://github.com/trelau/SMESH"
  url "https://github.com/trelau/SMESH.git", :using => :git
  version "0.1.0"

  depends_on "cmake" => :build

  def install
    
    system "#{Formula["#@tap/python3.9"].opt_bin}/pip3 install patch"
    system "#{Formula["#@tap/python3.9"].opt_bin}/python3 prepare.py"
    
    mkdir "Build" do
     system "cmake",  std_cmake_args , ".."
     system "make", "-j#{ENV.make_jobs}"
     system "make", "install"
    end
  end
  
  
end
