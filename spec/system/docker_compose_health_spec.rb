require 'rails_helper'

RSpec.describe "Docker Compose Health Check", type: :system do
  it "successfully loads the application homepage" do
    visit root_path
    
    # The application should be running and accessible
    # Check that we get a page with content (not an error)
    expect(page).to have_css('body')
  end

  it "renders the application layout" do
    visit root_path
    
    # Check for basic application structure
    # This will vary based on whether user is logged in or not
    expect(page).to have_css('body')
    
    # Check that no error pages are shown
    expect(page).not_to have_content('We\'re sorry, but something went wrong')
    expect(page).not_to have_content('The page you were looking for doesn\'t exist')
  end

  context "when accessing the application" do
    it "responds to health check requests" do
      # Direct HTTP check for health endpoint if one exists
      visit root_path
      
      # Verify the page loads without Rails errors
      expect(page).not_to have_content('ActionController::RoutingError')
      expect(page).not_to have_content('NoMethodError')
      expect(page).not_to have_content('NameError')
    end
  end
end