#!/bin/bash
curl -v --location 'http://localhost:8080/api/credit' \
--header 'Content-Type: application/json' \
--data '{
  "userId": 1,
	"amount": "500.0",
	"orderId": "fls3092njfsklj03"
}'
echo