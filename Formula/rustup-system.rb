class RustupSystem < Formula
  desc "Rustup managed by Homebrew (Arch Linux's approach)"
  homepage "https://rustup.rs"
  url "https://github.com/rust-lang/rustup/archive/refs/tags/1.24.3.tar.gz"
  sha256 "24a8cede4ccbbf45ab7b8de141d92f47d1881bb546b3b9180d5a51dc0622d0f6"
  license any_of: ["Apache-2.0", "MIT"]

  depends_on "rust" => :build

  uses_from_macos "curl"
  uses_from_macos "xz"

  on_linux do
    depends_on "pkg-config" => :build
    depends_on "openssl@1.1"
  end

  conflicts_with "rust"
  conflicts_with "rustup-init"

  def install
    system "cargo", "install", "--features", "no-self-update", "--bin", "rustup-init", *std_cargo_args
    File.rename "#{bin}/rustup-init", "#{bin}/rustup"

    %w[
      rustc
      rustdoc
      cargo
      rust-lldb
      rust-gdb
      rust-gdbgui
      rls
      rustfmt
      cargo-clippy
      clippy-driver
      cargo-miri
      cargo-fmt
    ].each do |proxy_symlink|
      ln_sf "#{bin}/rustup", "#{bin}/#{proxy_symlink}"
    end

    (bash_completion/"rustup").write Utils.safe_popen_read(bin/"rustup", "completions", "bash", "rustup")
    (bash_completion/"cargo").write  Utils.safe_popen_read(bin/"rustup", "completions", "bash", "cargo")
    (zsh_completion/"rustup").write  Utils.safe_popen_read(bin/"rustup", "completions", "zsh",  "rustup")
    (zsh_completion/"cargo").write   Utils.safe_popen_read(bin/"rustup", "completions", "zsh",  "cargo")
    (fish_completion/"rustup").write Utils.safe_popen_read(bin/"rustup", "completions", "fish", "rustup")
  end

  test do
    # TODO: This should be a proper actual test.
    system "cargo", "test", "--locked", "--release"
  end
end
