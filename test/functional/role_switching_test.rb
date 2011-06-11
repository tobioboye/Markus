require File.dirname(__FILE__) + '/authenticated_controller_test'
require File.join(File.dirname(__FILE__),'/../blueprints/blueprints')
require 'shoulda'
require 'machinist'

# re-raise errors caught by controller
class MainController; def rescue_action(e) raise e end; end

class RoleSwitchingTest < AuthenticatedControllerTest

  fixtures :all

  # TODO need to change username and password for valid logins when
  # actual authentication is in place (i.e. when User.verify is implemented)

  def setup
    @controller = MainController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  # Test if users with valid username and password can login and that
  # session parameters has been correctly set
  def test_correct_role_switch
    admin = users(:olm_admin_1)
    post :login, :user_login => admin.user_name, :user_password => 'asfd'
    assert_equal admin.id, session[:uid]
    post :login_as, :effective_user_login => "c5anthei", :user_login => admin.user_name, :admin_password => "adfadsf"
    assert_equal admin.id , session[:uid]
    assert_not_nil session[:timeout]
  end

  def test_index
    user = users(:student1)
    get_as user, :index
    assert_redirected_to :controller => 'assignments', :action => 'index'
  end

  def test_correct_logout
    admin = users(:olm_admin_1)
    post :login, :user_login => admin.user_name, :user_password => 'asfd'
    assert_equal admin.id, session[:uid]
    post :login_as, :effective_user_login => "c5anthei", :user_login => admin.user_name, :admin_password => "adfadsf"
    get :logout
    assert_redirected_to :action => "login"
    assert_nil session[:uid]
    assert_nil session[:timeout]

    # try to go back to a page
    get :index
    assert_redirected_to :action => "login", :controller => "main"
  end

  # Test if users see an error regarding missing information on login
  def test_blank_login_and_pwd
    admin = users(:olm_admin_1)
    post :login, :user_login => admin.user_name, :user_password => 'asfd'
    post :login_as, :user_login => "", :user_password => ""
    assert_not_equal "", flash[:login_notice]
  end

end
