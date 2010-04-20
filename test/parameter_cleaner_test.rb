require File.join(File.dirname(__FILE__), 'test_helper')
require "parameter_cleaner"

class ParameterCleaningTest < ActionController::TestCase
  class TestController < ActionController::Base
    do_not_escape_param :unescaped
    do_not_escape_param [:nested, :unescaped]
    layout nil

    def index
      render :nothing => true
    end
  end

  def params
    @request.params
  end

  tests TestController

  setup do
    ActionController::Routing::Routes.draw do |map|
      map.test_action "/test-action", :controller => "parameter_cleaning_test/test", :action => "index"
    end
  end

  should "remove <> from fields" do
    get :index, :field => "blah <> blah"
    assert_equal "blah  blah", params[:field]
  end

  should "remove <> from nested fields" do
    get :index, :nested => { :field => "blah <> blah" }
    assert_equal "blah  blah", params[:nested][:field]
  end

  should "remove <> from array fields" do
    get :index, :array => ["blah <> blah"]
    assert_equal ["blah  blah"], params[:array]
  end

  should "not remove <> from password fields" do
    get :index, :nested => {:password => "<><>", :password_confirmation => "<><>"}
    assert_equal "<><>", params[:nested][:password]
    assert_equal "<><>", params[:nested][:password_confirmation]
  end

  should "not remove <> from whitelisted field" do
    get :index, :unescaped => "<><>"
    assert_equal "<><>", params[:unescaped]
  end

  should "not remove <> from whitelisted nested field" do
    get :index, :nested => {:unescaped => "<><>"}
    assert_equal "<><>", params[:nested][:unescaped]
  end

  should "not remove <> from whitelisted array field" do
    get :index, :unescaped => ["<><>"]
    assert_equal ["<><>"], params[:unescaped]
  end
end
