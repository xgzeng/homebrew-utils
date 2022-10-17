class Cloak < Formula
    desc "A censorship circumvention tool to evade detection"
    homepage "https://github.com/cbeuw/Cloak"
    url "https://github.com/cbeuw/Cloak/archive/refs/tags/v2.6.0.tar.gz"
    sha256 "4c9b3699e97293d7ca0cf120eef199db31ca2e63cd0988d4b1f39be5ac84b507"
    license "GPL-3.0"
    head "https://github.com/cbeuw/Cloak.git", branch: "master"
  
    depends_on "go" => :build
  
    def install
        # ENV["GOPROXY"] = "https://goproxy.cn"
        system "go", "build", *std_go_args(output: bin/"ck-client"), "./cmd/ck-client"
        system "go", "build", *std_go_args(output: bin/"ck-server"), "./cmd/ck-server"
    end
end
