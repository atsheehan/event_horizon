require "rails_helper"

feature "guest creates account" do

  scenario "successful sign up with valid github credentials" do
    OmniAuth.config.mock_auth[:github] = {
      "provider" => "github",
      "uid" => "123456",
      "info" => {
        "nickname" => "boblob",
        "email" => "bob@example.com",
        "name" => "Bob Loblaw"
      }
    }

    visit root_path

    click_link "Sign In With GitHub"

    expect(page).to have_content("Signed in as boblob")
    expect(page).to have_link("Sign Out", session_path)

    expect(User.count).to eq(1)
  end

end
