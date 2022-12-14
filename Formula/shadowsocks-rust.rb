class ShadowsocksRust < Formula
  desc "Rust port of Shadowsocks"
  homepage "https://github.com/shadowsocks/shadowsocks-rust"
  url "https://github.com/shadowsocks/shadowsocks-rust/archive/v1.14.3.tar.gz"
  sha256 "a41437cdae1279914f11c07a584ab8b2b21e9b08bd732ef11fb447c765202215"
  license "MIT"
  head "https://github.com/shadowsocks/shadowsocks-rust.git", branch: "master"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args, "--features", "stream-cipher"
  end

  def post_install
    conf = etc/"shadowsocks-rust/local.json"
    return if conf.exist?
    conf.write <<~EOS
      {
        "server":"127.0.0.1",
        "server_port": 1234,
        "password":"mypassword",
        "method":"aes-256-gcm",
        "local_address":"127.0.0.1",
        "local_port": 1080
      }
    EOS
  end

  service do
    run [opt_bin/"sslocal", "-c", etc/"shadowsocks-rust/local.json"]
    keep_alive true
  end

  test do
    server_port = free_port
    local_port = free_port

    (testpath/"server.json").write <<~EOS
      {
          "server":"127.0.0.1",
          "server_port":#{server_port},
          "password":"mypassword",
          "method":"aes-256-gcm"
      }
    EOS
    (testpath/"local.json").write <<~EOS
      {
          "server":"127.0.0.1",
          "server_port":#{server_port},
          "password":"mypassword",
          "method":"aes-256-gcm",
          "local_address":"127.0.0.1",
          "local_port":#{local_port}
      }
    EOS
    fork { exec bin/"ssserver", "-c", testpath/"server.json" }
    fork { exec bin/"sslocal", "-c", testpath/"local.json" }
    sleep 3

    output = shell_output "curl --socks5 127.0.0.1:#{local_port} https://example.com"
    assert_match "Example Domain", output
  end
end
