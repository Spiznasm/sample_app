require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
    @unactivated_user = users(:cyril)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      if user.activated?
        assert_select 'a[href=?]', user_path(user), text: user.name
        unless user == @admin
          assert_select 'a[href=?]', user_path(user), text: 'delete'
        end
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

  test "only show activated users in index" do
    log_in_as(@admin)
    get users_path
    assert_select 'a', text: 'Sterling Archer', count: 1
    assert_select 'a', text: 'Cyril Figgis', count: 0
  end

  test "do not show unactivated users profile page" do
    log_in_as(@unactivated_user)
    get user_path(@unactivated_user)
    follow_redirect!
    assert_template 'static_pages/home'
  end

  test "show activated users profile page" do
    log_in_as(@non_admin)
    get user_path(@non_admin)
    assert_template 'users/show'
  end
end
