I will implement the backend logic to support the User Interface and Personal Center features. This includes extending the User entity, creating Data Transfer Objects (DTOs), and implementing the service and controller layers for profile management.

### 1. Enhance User Entity
I will update `src/main/java/com/example/demo/entity/User.java` to include fields required by the Personal Center:
- `nickname`: For display name.
- `bio`: For personal introduction.
- `tags`: To store interest tags (as a comma-separated string for simplicity).
- `contactInfo`: For contact details (WeChat/QQ).
- `avatarUrl`: To store the avatar path/URL.

### 2. Create DTOs (Data Transfer Objects)
I will create new DTO classes in `src/main/java/com/example/demo/dto` to handle data transfer safely:
- `UserProfileResponse.java`: To return user profile data to the frontend without exposing sensitive info like passwords.
- `UpdateProfileRequest.java`: To receive profile update data.
- `ChangePasswordRequest.java`: To receive password change requests.

### 3. Update UserService
I will add business logic to `src/main/java/com/example/demo/service/UserService.java`:
- `getUserProfile(Long userId)`: Retrieve user details.
- `updateUserProfile(Long userId, UpdateProfileRequest request)`: Update user information.
- `changePassword(Long userId, ChangePasswordRequest request)`: Verify old password and update to new password.

### 4. Create UserController
I will create a new controller `src/main/java/com/example/demo/controller/UserController.java` to expose REST APIs:
- `GET /api/users/{userId}`: Fetch user profile.
- `PUT /api/users/{userId}`: Update user profile.
- `POST /api/users/{userId}/password`: Change password.

### 5. Verification
- I will verify the implementation by compiling the code.
- I will provide the API endpoints that the frontend can now call to replace the mock `localStorage` logic.
