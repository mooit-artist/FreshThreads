# TODO: place your cursor at the end of line 6 and press Enter to generate a suggestion.
# Tip: press tab to accept the suggestion

fake_users = [
    { "name": "User 1", "id": "user1", "city": "San Francisco", "state": "CA" },
]

# Print the data to verify it's working
print("Fake users data:")
for user in fake_users:
    print(f"- {user['name']} ({user['id']}) from {user['city']}, {user['state']}")
