#!/bin/bash

curl -X POST "https://andmed.stat.ee/api/v1/et/stat/KK513" \
-H "Content-Type: application/json" \
-d '{
  "query": [
    {
      "code": "Maakond",
      "selection": {
        "filter": "item",
        "values": [
          "00",
          "37",
          "39",
          "44",
          "49",
          "51",
          "57",
          "59",
          "65",
          "67",
          "70",
          "74",
          "78",
          "82",
          "84",
          "86"
        ]
      }
    },
    {
      "code": "Hukkumise põhjus",
      "selection": {
        "filter": "item",
        "values": [
          "1",
          "2",
          "3",
          "4",
          "5",
          "6",
          "7",
          "8",
          "9"
        ]
      }
    }
  ],
  "response": {
    "format": "csv"
  }
}'
