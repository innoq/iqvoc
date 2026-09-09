require File.join(File.expand_path(File.dirname(__FILE__)), '../test_helper')
require 'tmpdir'
require 'zip'

class SkosExportLinkTest < ActiveSupport::TestCase
  NAMESPACE = 'http://hobbies.com/'

  setup do
    # realpath, because on macOS /var/folders is a symlink to /private/var
    # and File.realpath on the link would resolve that too
    @dir = File.realpath(Dir.mktmpdir('iqvoc-export-link-test'))
    @link = File.join(@dir, 'stable.nt')
  end

  teardown do
    FileUtils.remove_entry(@dir)
  end

  test 'link points at the file that was just written' do
    dump = export('dump-2026-09-09.nt', link_path: @link)

    assert File.symlink?(@link), "expected '#{@link}' to be a symlink"
    assert_equal dump, File.realpath(@link)
    assert_equal File.read(dump), File.read(@link)
  end

  test 'link target is relative so it survives a move of the export directory' do
    export('dump-2026-09-09.nt', link_path: @link)

    assert_equal 'dump-2026-09-09.nt', File.readlink(@link)
  end

  test 'link target stays relative across directories' do
    dump = export('archive/dump-2026-09-09.nt', link_path: @link)

    assert_equal 'archive/dump-2026-09-09.nt', File.readlink(@link)
    assert_equal dump, File.realpath(@link)
  end

  test 'link is moved on to the most recent export' do
    outdated = export('dump-2026-09-08.nt', link_path: @link)
    current = export('dump-2026-09-09.nt', link_path: @link)

    assert File.exist?(outdated), 'expected the outdated export to be kept'
    assert_equal current, File.realpath(@link)
  end

  test 'link replaces a pre-existing regular file' do
    File.write(@link, 'previously served by hand')
    dump = export('dump-2026-09-09.nt', link_path: @link)

    assert File.symlink?(@link)
    assert_equal dump, File.realpath(@link)
  end

  test 'link directory is created when missing' do
    link = File.join(@dir, 'public', 'stable.nt')
    dump = export('dump-2026-09-09.nt', link_path: link)

    assert_equal dump, File.realpath(link)
  end

  test 'no temporary symlink is left behind' do
    export('dump-2026-09-09.nt', link_path: @link)

    assert_empty Dir.glob(File.join(@dir, '*.tmp*'))
  end

  test 'nothing is linked without a link path' do
    export('dump-2026-09-09.nt')

    assert_empty Dir.glob(File.join(@dir, '*')).select { |path| File.symlink?(path) }
  end

  # the archive entry is derived from the real file name, which is what makes
  # the creation date visible after unpacking a download made through the link
  test 'archive entry read through the link carries the name of the dump' do
    link = File.join(@dir, 'stable.nt.zip')
    export('dump-2026-09-09.nt.zip', zip: true, link_path: link)

    entries = Zip::File.open(link) { |archive| archive.entries.map(&:name) }
    assert_equal ['dump-2026-09-09.nt'], entries
  end

  private

  # writes an export below the temporary directory, returns its absolute path
  def export(filename, **options)
    file_path = File.join(@dir, filename)
    SkosExporter.new(file_path, 'nt', NAMESPACE, Logger.new(IO::NULL), **options).run
    file_path
  end
end
