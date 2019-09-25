# This was copied from Samuel Cochran's sj26/homebrew-core repo; I just made a
# tap out of it.
class NginxUnit < Formula
  desc "Dynamic web and application server for multiple languages"
  homepage "https://unit.nginx.org/"
  url "https://unit.nginx.org/download/unit-1.11.0.tar.gz"
  sha256 "da52e884743a08a3ee202ebd1cc21154ac527427d195f0edc003c26e0779b5ca"
  head "https://hg.nginx.org/unit", :using => :hg

  option "with-debug", "Build with debug logging enabled"

  depends_on "openssl"
  depends_on "pcre"

  depends_on "go" => :optional
  depends_on "perl" => :optional
  depends_on "python" => :optional
  depends_on "ruby" => :optional

  def install
    openssl = Formula["openssl"]
    pcre = Formula["pcre"]

    configure_args = [
      "--prefix=#{prefix}",
      "--bindir=#{bin}",
      "--sbindir=#{bin}",
      "--modules=#{lib}/unit",
      "--state=#{var}/unit",
      "--log=#{var}/log/unit.log",
      "--pid=#{var}/run/unit.pid",
      "--control=unix:#{var}/run/unit.control.sock",
      "--cc-opt=-I#{pcre.opt_include} -I#{openssl.opt_include}",
      "--ld-opt=-L#{pcre.opt_lib} -L#{openssl.opt_lib}",
    ]

    if build.with? "debug"
      configure_args << "--debug"
    end

    system "./configure", *configure_args

    if build.with? "go"
      system "./configure", "go"
    end

    if build.with? "perl"
      system "./configure", "perl"
    end

    if build.with? "python"
      system "./configure", "python"
    end

    if build.with? "ruby"
      system "./configure", "ruby"
    end

    system "make", "install"
  end

  def caveats
    <<~EOS
      Once running, you can control unit using the control socket, for example using curl:
        curl --unix-socket #{var}/run/unit.control.sock http://localhost/
    EOS
  end

  plist_options :manual => "unitd"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>ProgramArguments</key>
        <array>
            <string>#{bin}/unitd</string>
            <string>--no-daemon</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/unitd", "--version"
  end
end

