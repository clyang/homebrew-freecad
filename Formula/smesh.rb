class Smesh < Formula
  desc "A stand-alone library of the mesh framework from the Salome Platform."
  homepage "https://github.com/trelau/SMESH"
  url "https://github.com/trelau/SMESH.git", :using => :git
  version "0.1.0"

  depends_on "cmake" => :build

  def install
    
    system "python prepare.py"
    
    mkdir "Build" do
     system "cmake",  *args , ".."
     system "make", "-j#{ENV.make_jobs}"
     system "make", "install"
    end
  end
  
  
end
