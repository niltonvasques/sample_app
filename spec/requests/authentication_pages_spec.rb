require 'spec_helper'

describe "Authentication" do
  subject { page }
  let(:signin) { "Sign in" }

  describe "signin page" do
    before { visit signin_path }

    it { should have_selector('h1',     text: 'Sign in') }
    it { should have_right_title('Sign in') }
  end

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button signin }

      it { should have_right_title('Sign in') }
      it { should have_error_message('Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }

        it { should_not have_error_message('Invalid') }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_signin(user) } 

      describe "should have right links" do
        it { should have_right_title(user.name) }
        it { should have_link('Profile',      href: user_path(user)) }
        it { should have_link('Sign out',     href: signout_path) }
        it { should have_link('Users') }
        it { should_not have_link('Sign in',  href: signin_path) }
      end

      describe "followed by sign out" do
        before { click_link "Sign out" }
        it { should have_link("Sign in") }
      end
    end
  end
    
end
