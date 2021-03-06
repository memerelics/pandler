require "pathname"

describe Pandler::Chroot do
  include TempDirHelper
  before :all do
#    @base_dir = File.expand_path("../../../.spec_cache", __FILE__)
    yumrepo = "file://" + File.expand_path("../../resources/yumrepo", __FILE__)
    @chroot = Pandler::Chroot.new(:yumrepo => yumrepo)
  end

  subject { @chroot }
  its(:root_dir) { should eq "#{@chroot.base_dir}/root" }

  describe "chroot file path" do
    subject { @chroot.real_path("/") }
    it { should eq @chroot.root_dir + "/" }
  end

  describe "init" do
    before(:all) { @chroot.init }
    it "should create directories" do
      [
        '/var/lib/rpm',
        '/var/lib/yum',
        '/var/lib/dbus',
        '/var/log',
        '/var/lock/rpm',
        '/var/cache/yum',
        '/etc/rpm',
        '/tmp',
        '/tmp/ccache',
        '/var/tmp',
        '/etc/yum.repos.d',
        '/etc/yum',
        '/proc',
        '/sys',
      ].each do |path|
        Pathname(@chroot.real_path(path)).should exist
      end
    end
    it "should create files" do
      [
        '/etc/mtab',
        '/etc/fstab',
        '/var/log/yum.log',
        '/etc/yum/yum.conf',
        '/etc/yum.conf',
        '/etc/resolv.conf',
        '/etc/hosts',
      ].each do |path|
        Pathname(@chroot.real_path(path)).should exist
      end
    end
    it "should create devs" do
      [
        '/dev/null',
        '/dev/full',
        '/dev/zero',
        '/dev/random',
        '/dev/urandom',
        '/dev/tty',
        '/dev/console',
        '/dev/stdin',
        '/dev/stdout',
        '/dev/stderr',
        '/dev/fd',
#        '/dev/ptmx',
      ].each do |path|
        Pathname(@chroot.real_path(path)).should exist
      end
    end
  end

  describe "install first time" do
    before(:all) { @chroot.install("pandler-test-0.0.1-1.x86_64", "pandler-test-a-0.0.1-1.x86_64") }
    it "should execute /pandler-test" do
      Kernel.system("chroot", @chroot.root_dir, "/pandler-test").should be_true
    end
  end

  describe "exec /pandler-test" do
    subject { capture_stdout { @chroot.execute("/pandler-test") } }
    it { should eq "pandler test\n" }
  end

  describe "install second time" do
    before(:all) { @chroot.install("pandler-test-0.0.1-1.x86_64") }
    subject { @chroot.installed_pkgs }
    it { should eq ["pandler-test-0.0.1-1.x86_64"] }
  end

  after(:all) { @chroot.clean }
end
