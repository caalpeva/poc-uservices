#!/bin/bash
#export BASE_URL=http://localhost:8080
#export ACTION=POST
#export URL="$BASE_URL/orders/cancel"
#echo Sending request to "$ACTION" "$URL"
#curl -i --location --request "$ACTION" "$URL" \

curl -i --location 'http://localhost:8888/orders' \
--header 'Cache-Control: no-cache' \
--header 'Content-Type: application/json' \
--data-raw '{
    "client": {
        "id": "41423087",
        "email": "setota1980@gmail.com",
        "documentNumber": "74122250C",
        "name": "SEGUNDO",
        "surname": "TORO DE LA TARDE",
        "phoneNumber": "691856480"
    },
    "line": {
        "type": "Mobile",
        "phoneNumber": "622560327",
        "portabilityType": "New"
    },
    "services": [
        {
            "characteristics": [
                {
                    "name": "BILLING_TYPE",
                    "value": "POSTPAID"
                },
                {
                    "name": "Balance",
                    "value": "0.0"
                },
                {
                    "name": "PROFILE_SMS",
                    "value": true
                },
                {
                    "name": "PROFILE_VOICE",
                    "value": true
                },
                {
                    "name": "PROFILE_DATA",
                    "value": true
                },
                {
                    "name": "DATA_PLAN",
                    "value": "LLy_PLAN_POST01"
                },
                {
                    "name": "DATA_BONUS",
                    "value": [
                        "MB_BONO_DAT_50GB"
                    ]
                }
            ],
            "action": "Add",
            "name": "DEFAULT_LLAMAYA_RATE",
            "type": "CONTRACT"
        },
        {
            "characteristics": [
                {
                    "name": "ICCID",
                    "value": "8934046421070057035"
                },
                {
                    "name": "IMSI",
                    "value": "214042802685817"
                },
                {
                    "name": "KI",
                    "value": "34E41C4EE4A97923A4276139159DCF53"
                }
            ],
            "action": "Add",
            "name": "SIM",
            "type": "SIM"
        },
        {
            "action": "Add",
            "name": "LLY_Roaming",
            "type": "PricePlan"
        }
    ],
    "brand": "LLAMAYA",
    "createdBy": "mb6offline",
    "createdDate": "2022-10-28T13:15:32.000+02:00",
    "orderId": "NEW_58585127_722560327",
    "orderType": "InOrder"
}'
echo