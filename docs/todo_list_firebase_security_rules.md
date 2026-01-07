# Todo List Firebase Realtime Database Security Rules

This document provides the Firebase Realtime Database security rules for the todo list feature.

## Security Rules

Add these rules to your Firebase Console under Realtime Database → Rules:

```json
{
  "rules": {
    "todos": {
      "$userId": {
        ".read": "$userId === auth.uid",
        ".write": "$userId === auth.uid",
        "$todoId": {
          ".validate": "newData.hasChildren(['id', 'title', 'createdAt', 'updatedAt', 'userId']) && newData.child('userId').val() === $userId"
        }
      }
    }
  }
}
```

## Rules Explanation

### Path Structure

```
/todos/{userId}/{todoId}
```

### Rule Details

1. **`.read": "$userId === auth.uid"`**
   - Users can only read their own todos
   - Each user's todos are stored under `/todos/{userId}/`
   - The authenticated user's UID must match the `$userId` path parameter

2. **`.write": "$userId === auth.uid"`**
   - Users can only write (create/update/delete) their own todos
   - Prevents users from modifying other users' data

3. **`.validate": "newData.hasChildren(['id', 'title', 'createdAt', 'updatedAt', 'userId']) && newData.child('userId').val() === $userId"`**
   - Validates that all required fields are present when writing data
   - Required fields: `id`, `title`, `createdAt`, `updatedAt`, `userId`
   - Ensures `userId` in the data matches the path `$userId`
   - Prevents data corruption and unauthorized access

## Security Considerations

1. **Authentication Required**: All operations require authentication. Unauthenticated users cannot access any todo data.

2. **Data Isolation**: Each user's data is completely isolated. User A cannot read or modify User B's todos.

3. **Data Validation**: The validation rule ensures data integrity by requiring all essential fields.

4. **No Index Listing**: The rules prevent listing all users' todo collections at the `/todos/` level since read/write rules are only granted at the user-specific path.

## Testing Security Rules

You can test these rules using the Firebase Console Simulator:

1. Go to Firebase Console → Realtime Database → Rules
2. Click "Rules Playground"
3. Test various scenarios:
   - Authenticated user reading their own todos: ✅ Should succeed
   - Authenticated user reading another user's todos: ❌ Should fail
   - Authenticated user writing to their own path: ✅ Should succeed
   - Unauthenticated user attempting to read: ❌ Should fail
   - Writing data without required fields: ❌ Should fail
   - Writing data with mismatched userId: ❌ Should fail

## Deployment

After updating rules:

1. Review the rules in the Firebase Console
2. Test using the Rules Playground
3. Publish the rules
4. Verify the app continues to work correctly
5. Monitor Firebase Console logs for any rule violations

## Related Documentation

- [Todo List Firebase Realtime Database Plan](todo_list_firebase_realtime_database_plan.md)
- [Firebase Realtime Database Security Rules Documentation](https://firebase.google.com/docs/database/security)

