require File.expand_path("../integration_test_helper", File.dirname(__FILE__))

class EnvironmentTest < Scope::TestCase
  context "environment" do

    destination :vagrant do
      env :hero, "mario"
      env :villain, "bowser", :hosts => [VAGRANT_DOMAIN]
    end

    should "store environment settings" do
      assert_equal "mario", Fezzik.environments[VAGRANT_DOMAIN][:hero]
    end

    should "store environment settings for a subset of hosts" do
      # This isn't actually a great test for this, but testing with multiple hosts would require a second
      # vagrant configuration.
      assert_equal "bowser", Fezzik.environments[VAGRANT_DOMAIN][:villain]
    end
  end
end

