I will modify `src/main/resources/static/profile.html` to connect the frontend to the backend API.

The plan involves:

1.  **Fetching User Data on Load**:
    -   Inside `DOMContentLoaded`, after checking login status, I will make a `GET` request to `/api/users/{userId}` using `fetch`.
    -   I will populate the form fields (`nicknameInput`, `bio` textarea, `contactInfo` input) and the tags area with the data received from the backend.
    -   I will update the `userAvatar` and `largeAvatarText` based on the fetched nickname or username.

2.  **Handling Profile Updates**:
    -   I will update the `profileForm` submit handler.
    -   Instead of the alert, it will collect data from the form inputs (nickname, bio, contact info).
    -   It will also collect tags from the tag area. I need to make sure I can read the tags correctly from the DOM.
    -   It will send a `PUT` request to `/api/users/{userId}` with the collected JSON data.
    -   On success, it will alert "Save successful".

3.  **Handling Password Changes**:
    -   I will add an ID to the security form (e.g., `id="securityForm"`).
    -   I will add IDs to the password inputs (`oldPassword`, `newPassword`, `confirmNewPassword`).
    -   I will add a submit event listener to this form.
    -   It will validate that the new passwords match.
    -   It will send a `POST` request to `/api/users/{userId}/password` with `oldPassword` and `newPassword`.

4.  **Handling Tag Input Logic**:
    -   The current tag input logic is static HTML. I need to ensure the JavaScript can dynamically render tags from the backend and also allow adding/removing tags properly, updating the DOM so that the save function can collect them.
    -   I will implement a simple `renderTags` function and `addTag` / `removeTag` logic.

5.  **Verification**:
    -   I will verify by explaining that the user can now log in, go to the profile page, see their info (initially empty or default), edit it, save, reload the page, and see the persisted data.
