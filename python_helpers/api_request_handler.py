import requests as req

url = 'https://csapi.singlecare.com/services/v1_0/private/CRMService.svc/LogDropOffKit'

payload = "{\r\n    \"LocationId\": \"230408\",\r\n    \"MemberNumber\": \"123456789\",\r\n    \"GroupNumber\": \"000000\",\r\n    \"Authentication\": {\r\n        \"ApiToken\": \"JFUzF9wSxgCSnR2Wawe4vnPQQYeLaNJzXe8Y3bpZ\",\r\n        \"UserId\": \"16504313\"\r\n    }\r\n}"

headers = {
    'Content-Type': 'application/json',
    'Cookie': '__RequestVerificationToken=XNPFrncou5bnM4eJQpQSRM0EPc8QUZa87DijvfAXacF_VJjYGfCTZMQrgmdhk9-emfWjNqSp4d70SjglivXIR8ZNxKoph9cg-oERJKwcKHc1'
}

result = req.request("POST", url, data=payload)

print(result.text.encode('utf8'))


def log_kits_api(location_ids, member_numbers, group_number, api_token, user_id):
    print(location_ids)
    print(member_numbers)
    print(group_number)
    print(api_token)
    print(user_id)
