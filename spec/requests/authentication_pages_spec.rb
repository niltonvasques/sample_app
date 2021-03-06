require 'spec_helper'

describe "Authentication" do
  subject { page }
  let(:signin) { "Sign in" }

  describe "signin page" do
    before { visit signin_path }

    it { should have_selector('h1',     text: 'Sign in') }
    it { should have_title('Sign in') }
  end

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button signin }

      it { should have_title('Sign in') }
      it { should have_error_message('Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }

        it { should_not have_error_message('Invalid') }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user } 

      it { should have_title(user.name) }
        
      describe "should have right links" do
        it { should have_link('Users',        href: users_path) }
        it { should have_link('Profile',      href: user_path(user)) }
        it { should have_link('Settings',     href: edit_user_path(user)) }
        it { should have_link('Sign out',     href: signout_path) }
        it { should_not have_link('Sign in',  href: signin_path) }
      end

      describe "followed by sign out" do
        before { click_link "Sign out" }
        it { should have_link("Sign in") }
        
        describe "should have right links" do
          it { should_not have_link('Users',        href: users_path) }
          it { should_not have_link('Profile',      href: user_path(user)) }
          it { should_not have_link('Settings',     href: edit_user_path(user)) }
          it { should_not have_link('Sign out',     href: signout_path) }
          it { should have_link('Sign in',  href: signin_path) }
        end
      end

      describe "when try sign-up other user" do
        before { visit signup_path }
        it "should be redirect to root path" do
          should_not have_title('Sign up')
        end
      end

      describe "when try create a user" do
        it "should not create" do
          post_attributes = FactoryGirl.attributes_for(:user)
          expect { post users_path, user: post_attributes }.not_to change(User, :count)
        end
      end
    end
  end

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users controller" do

        describe "when attempting to visit a protected page" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }

          describe "after signing in" do
            before do
              fill_in "Email",      with: user.email
              fill_in "Password",   with: user.password
              click_button "Sign in"
            end

            it "should render the desired protected page" do
              should have_title('Edit user')
            end

            describe "when attempt signing again" do
              before { visit signin_path }
              it { should_not have_title('Sign in') }              
            end
          end
        end

        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end

        describe "visiting the users index" do
          before { visit users_path }
          it { should have_title('Sign in') }
        end

        describe "visiting the following page" do
          before { visit following_user_path(user) }
          it { should have_title('Sign in') }
        end
        
        describe "visiting the followers page" do
          before { visit followers_user_path(user) }
          it { should have_title('Sign in') }
        end
      end

      describe "in the Relationships controller" do
        describe "submitting to the create action" do
          before { post relationships_path }
          specify { response.should redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete relationship_path(1) }
          specify { response.should redirect_to(signin_path) }
        end
      end

      describe "in the Microposts controller" do
        describe "submitting to the create action" do
          before { post microposts_path }
          specify { response.should redirect_to(signin_path)}
        end

        describe "submitting to the destroy action" do
          before do
            micropost = FactoryGirl.create(:micropost)
            delete micropost_path(micropost)
          end
          specify { response.should redirect_to(signin_path) }
        end
      end
    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user }

      describe "visiting the Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_title(full_title('Edit user')) }
      end

      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }
      end
    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_path) }
      end
    end
  end
    
end
