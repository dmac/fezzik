require File.expand_path("../integration_test_helper", File.dirname(__FILE__))

class BaseTest < Scope::TestCase
  context "base" do

    namespace :fezzik do
      remote_task(:touch, :path) { |t, args| run "touch #{args[:path]}" }
      remote_task(:rm, :path) { |t, args| run "rm #{args[:path]}" }
    end

    should "create and delete files on the remote host" do
      fez :touch, "/tmp/touch"
      assert_file_exists("/tmp/touch")

      fez :rm, "/tmp/touch"
      refute_file_exists("/tmp/touch")
    end
  end
end
