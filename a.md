I want it follow this flow: In the login page, when the user press forget password -> Supabase send them an email -> User click on the link -> It navigate user to reset_password_page -> User input new password and confirm it -> Supabase update user password -> Navigate user to login page -> User can login with new password
Some important note:
- Config AndroidManifest.xml the deeplink
- Config the supabase to allow the deeplink
- Ensure that the deeplink is working
- Ensure that user when click on the link, it navigate to the reset_password_page not login to home_page

