class Libexif < Formula
  desc "EXIF parsing library"
  homepage "https://libexif.github.io/"
  url "https://github.com/libexif/libexif/releases/download/v0.6.23/libexif-0.6.23.tar.xz"
  sha256 "a740a99920eb81ae0aa802bb46e683ce6e0cde061c210f5d5bde5b8572380431"
  license "LGPL-2.1"

  bottle do
    sha256 arm64_big_sur: "33b373742f33b8f182efd02d8bd6387db49a6f96c9cb13868f904ae59791c99d"
    sha256 big_sur:       "93faf9081e80a6b1b30fd4dd941fa650d431b3064aeef00c9a7bccd042ff1bda"
    sha256 catalina:      "7379f6990018006122bba69098864e8877e8e6e7be3af535f7e301d8ff097e98"
    sha256 mojave:        "c20d311fbd1846ce2603950ec9ad9b3b6e8202bf2f97e9aab328c05dc568fcfe"
    sha256 high_sierra:   "8b1c7cf6ec777090ce22ccf5c426867948a54da9378e0c9b91d85175eaea4f81"
    sha256 x86_64_linux:  "69c7d9fd5fcab7af3afcfe802d5cb7b9a0523a6e83c637119c86b72a2356aea1"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "gettext"

  def install
    system "autoreconf", "-ivf"
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <libexif/exif-loader.h>

      int main(int argc, char **argv) {
        ExifLoader *loader = exif_loader_new();
        ExifData *data;
        if (loader) {
          exif_loader_write_file(loader, argv[1]);
          data = exif_loader_get_data(loader);
          printf(data ? "Exif data loaded" : "No Exif data");
        }
      }
    EOS
    flags = %W[
      -I#{include}
      -L#{lib}
      -lexif
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    test_image = test_fixtures("test.jpg")
    assert_equal "No Exif data", shell_output("./test #{test_image}")
  end
end
