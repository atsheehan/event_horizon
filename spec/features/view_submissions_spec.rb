require "rails_helper"

feature "view submissions" do
  let(:challenge) { FactoryGirl.create(:challenge) }

  context "as a user" do
    let(:user) { FactoryGirl.create(:user) }

    before :each do
      sign_in_as(user)
    end

    scenario "see my submissions for a challenge" do
      my_submissions = FactoryGirl.
        create_list(:submission, 2, challenge: challenge, user: user)
      other_submissions = FactoryGirl.
        create_list(:submission, 2, challenge: challenge)

      visit challenge_submissions_path(challenge)

      my_submissions.each do |submission|
        expect(page).to have_link_href(submission_path(submission))
      end

      other_submissions.each do |submission|
        expect(page).to_not have_link_href(submission_path(submission))
      end
    end

    scenario "see public submissions from other users" do
      my_submission = FactoryGirl
        .create(:submission, challenge: challenge, user: user)
      submissions = FactoryGirl.
        create_list(:submission, 3, challenge: challenge, public: true)

      visit challenge_submissions_path(challenge)

      submissions.each do |submission|
        expect(page).to have_content(submission.user.username)
        expect(page).to have_link_href(submission_path(submission))
      end

      submission = submissions[0]

      visit submission_path(submission)
      expect(page).to have_content("Submission for #{submission.challenge.title}")
      expect(page).to have_content(submission.user.username)
    end

    scenario "hide other public submissions if haven't submitted once" do
      submission = FactoryGirl
        .create(:submission, challenge: challenge, public: true)

      visit challenge_submissions_path(challenge)

      expect(page).to_not have_content(submission.user.username)
      expect(page).to_not have_link_href(submission_path(submission))

      expect(page).to have_content(
        "Other submissions hidden until you've submitted yours.")
    end

    scenario "view submission with multiple files" do
      submission = FactoryGirl.create(:submission, user: user)
      FactoryGirl.create(:source_file,
                         submission: submission,
                         filename: "bar.rb",
                         body: "b = 2")
      FactoryGirl.create(:source_file,
                         submission: submission,
                         filename: "foo.rb",
                         body: "a = 1")

      visit submission_path(submission)

      expect(page).to have_content("foo.rb")
      expect(page).to have_content("a = 1")
      expect(page).to have_content("bar.rb")
      expect(page).to have_content("b = 2")

      expect(page).to order_text("bar.rb", "foo.rb")
    end
  end

  context "as an admin" do
    let(:admin) { FactoryGirl.create(:admin) }

    before :each do
      sign_in_as(admin)
    end

    scenario "see all of the submissions for a challenge" do
      submissions = FactoryGirl.
        create_list(:submission, 3, challenge: challenge)

      visit challenge_submissions_path(challenge)

      submissions.each do |submission|
        expect(page).to have_link_href(submission_path(submission))
      end
    end

    scenario "view submission from student" do
      submission = FactoryGirl.create(:submission_with_file,
                                      challenge: challenge)

      visit submission_path(submission)

      expect(page).to have_content("Submission for #{challenge.title}")
      expect(page).to have_content(submission.user.username)
    end
  end

  context "as a guest" do
    scenario "redirect to login" do
      visit challenge_submissions_path(challenge)

      expect(page).to have_content("You need to sign in before continuing.")
      expect(page).to_not have_content("Submissions for #{challenge.title}")
    end
  end
end
