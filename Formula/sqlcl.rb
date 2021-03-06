class CacheDownloadStrategy < CurlDownloadStrategy
  def fetch(timeout: nil, **options)
    archive = @url.sub(%r[^file://], "")
    unless File.exists?(archive)
      odie <<~EOS
        Formula expects to locate the following archive:
          #{Pathname.new(archive).basename}
        in the HOMEBREW_CACHE directory:
          #{HOMEBREW_CACHE}
        Copy the archive to the cache or create a symlink in the cache to the archive:
          ln -sf /path/to/archive $(brew --cache)/
      EOS
    end
    super
  end
end

class Sqlcl < Formula
  desc "Free, Java-based command-line interface for Oracle databases"
  homepage "https://www.oracle.com/database/technologies/appdev/sqlcl.html"
  url "file://#{HOMEBREW_CACHE}/sqlcl-21.3.0.278.1045.zip",
    using: CacheDownloadStrategy
  sha256 "e9d0cbf6df9de57daf437b7c9125cdcccf1e478028946392f180bc0a3a42c908"

  depends_on arch: :x86_64
  depends_on "openjdk"

  def install
    # Remove Windows files
    rm_f "bin/sql.exe"

    prefix.install "README.md", "bin/license.txt"
    rm_f "21.3.0.278.1045"
    rm_f "bin/README.md"
    rm_f "bin/dependencies.txt"
    rm_f "bin/version.txt"
    rm_f "lib/pom.xml"

    bin.install "bin/sql" => "sqlcl"
    libexec.install "lib"
    bin.env_script_all_files(libexec/"bin", JAVA_HOME: Formula["openjdk"].opt_prefix)
  end

  test do
    system bin/"sqlcl", "-V"
  end
end

