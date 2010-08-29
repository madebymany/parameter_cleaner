require File.join(File.dirname(__FILE__), 'test_helper')
require "parameter_cleaner"

class ParameterCleaningTest < ActionController::TestCase
  class TestController < ActionController::Base
    do_not_clean_param :uncleaned
    do_not_clean_param [:nested, :uncleaned]
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

  should "remove XSS attack vectors" do
    get :index, :field => "blah '';!--\"<XSS>=&{()} blah"
    assert_equal "blah '';!--\"XSS=&{()} blah", params[:field]
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
    get :index, :uncleaned => "<><>"
    assert_equal "<><>", params[:uncleaned]
  end

  should "not remove <> from whitelisted nested field" do
    get :index, :nested => {:uncleaned => "<><>"}
    assert_equal "<><>", params[:nested][:uncleaned]
  end

  should "not remove <> from whitelisted array field" do
    get :index, :uncleaned => ["<><>"]
    assert_equal ["<><>"], params[:uncleaned]
  end

  should "not try to clean uploaded files" do
    io = StringIO.new("<><>")
    get :index, :upload => io
    assert_equal "<><>", params[:upload].read
  end
end
